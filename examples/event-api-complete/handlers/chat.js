/**
 * Chat Channel Handler
 *
 * This handler manages pub/sub events for a real-time chat application.
 * It demonstrates filtering, transformation, authorization, and rate limiting.
 *
 * Runtime: APPSYNC_JS 1.0.0
 * Use Case: Multi-room chat with user authentication and content moderation
 *
 * @see https://docs.aws.amazon.com/appsync/latest/eventapi/channel-namespace-handlers.html
 */

import { util } from "@aws-appsync/utils";

/**
 * Handle message publishing to chat channels
 *
 * Receives ctx.events (array of { id, payload }) and returns the processed
 * events array. Use util.error() to reject the entire publish operation.
 * Return per-event error objects to reject individual events.
 *
 * @param {Object} ctx - Context object
 * @param {Array} ctx.events - Array of events being published, each with { id, payload }
 * @param {Object} ctx.identity - Publisher identity
 * @param {Object} ctx.info - Channel and namespace information
 * @returns {Array} Processed events array to broadcast to subscribers
 */
export function onPublish(ctx) {
  const { events, identity, info } = ctx;

  // Extract channel information
  // Example channel: /chat/room-123
  const channelParts = info.channel.path.split("/");
  const roomId = channelParts[channelParts.length - 1];

  // 1. Authorization: Check if user is member of this chat room
  if (!isUserInRoom(identity, roomId)) {
    util.error("You must be a member of this chat room to send messages");
  }

  // 2. Rate Limiting: Prevent spam (rejects entire publish)
  if (isRateLimited(identity.sub, roomId)) {
    util.error("You are sending messages too quickly. Please slow down.");
  }

  // 3. Process each event individually
  return events.map((event) => {
    const data = event.payload;

    // Content Validation: Check message structure
    if (!data.message || typeof data.message !== "string") {
      return {
        id: event.id,
        error: "Message content is required and must be a string",
      };
    }

    // Content Moderation: Filter inappropriate content
    if (containsProfanity(data.message)) {
      return {
        id: event.id,
        error: "Message contains inappropriate content",
      };
    }

    // Size Validation: Enforce message limits
    const maxLength = data.type === "text" ? 2000 : 500;
    if (data.message.length > maxLength) {
      return {
        id: event.id,
        error: `Message exceeds maximum length of ${maxLength} characters`,
      };
    }

    // Data Transformation: Enrich message with metadata
    return {
      id: event.id,
      payload: {
        ...data,
        messageId: generateMessageId(),
        userId: identity.sub,
        username:
          identity.username || identity.email?.split("@")[0] || "Anonymous",
        roomId: roomId,
        timestamp: util.time.nowISO8601(),
        edited: false,
      },
    };
  });
}

/**
 * Handle subscription requests to chat channels
 *
 * To deny a subscription, call util.unauthorized() which returns a subscribe_error
 * with an Unauthorized error type (HTTP 401 for HTTP connections).
 * To allow a subscription, return null.
 *
 * @param {Object} ctx - Context object
 * @param {Object} ctx.args - Subscribe arguments
 * @param {string} ctx.args.channelName - Channel name being subscribed to
 * @param {Object} ctx.identity - Subscriber identity
 * @param {Object} ctx.info - Channel and namespace information
 */
export function onSubscribe(ctx) {
  const { channelName } = ctx.args;
  const { identity } = ctx;

  // Extract room ID from channel name
  // Example channel: /chat/room-123
  const channelParts = channelName.split("/");
  const roomId = channelParts[channelParts.length - 1];

  // 1. Authentication Check: Ensure user is logged in
  if (!identity.sub && !identity.username) {
    util.unauthorized();
    return;
  }

  // 2. Authorization: Check room membership
  if (!isUserInRoom(identity, roomId)) {
    util.unauthorized();
    return;
  }

  // 3. Concurrent Connection Limit
  const activeConnections = getUserConnectionCount(identity.sub);
  if (activeConnections >= 5) {
    util.unauthorized();
    return;
  }

  // 4. Private Room Check
  if (isPrivateRoom(roomId) && !hasPrivateAccess(identity, roomId)) {
    util.unauthorized();
    return;
  }

  // 5. Subscription allowed - return null to permit
  return null;
}

// ========================================
// Helper Functions (Implementation Stubs)
// ========================================

/**
 * Check if user is a member of the chat room
 * In production: Query DynamoDB table with room memberships
 */
function isUserInRoom(identity, roomId) {
  // Stub: In real implementation, check room_members table
  // Example: const result = await ddb.query({...});
  // For demo purposes, allow all authenticated users
  return identity.sub || identity.username;
}

/**
 * Check if user has exceeded rate limit
 * In production: Use Redis or DynamoDB with TTL for rate limiting
 */
function isRateLimited(userId, roomId) {
  // Stub: Check rate limit (e.g., 10 messages per minute)
  // Example: const count = await redis.incr(`rate:${userId}:${roomId}`);
  // For demo purposes, no rate limiting
  return false;
}

/**
 * Check message for profanity
 * In production: Use AWS Comprehend or external moderation API
 */
function containsProfanity(message) {
  // Simple word list check (production would use ML-based detection)
  const bannedWords = ["spam", "badword1", "badword2"];
  const lowerMessage = message.toLowerCase();
  return bannedWords.some((word) => lowerMessage.includes(word));
}

/**
 * Generate unique message ID
 */
function generateMessageId() {
  // In production: Use UUID or ULID
  return `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Get user's active connection count
 * In production: Track connections in DynamoDB or Redis
 */
function getUserConnectionCount(userId) {
  // Stub: Return mock count
  return 1;
}

/**
 * Check if room is private
 */
function isPrivateRoom(roomId) {
  // Check if room ID starts with 'private-'
  return roomId.startsWith("private-");
}

/**
 * Check if user has private room access
 */
function hasPrivateAccess(identity, roomId) {
  // In production: Check permissions table
  // For demo: Admins have access
  const userRoles = identity.claims?.["cognito:groups"] || [];
  return userRoles.includes("admin") || userRoles.includes("moderator");
}
