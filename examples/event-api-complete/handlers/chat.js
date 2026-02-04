/**
 * Chat Channel Handler
 *
 * This handler manages pub/sub events for a real-time chat application.
 * It demonstrates filtering, transformation, authorization, and rate limiting.
 *
 * Runtime: APPSYNC_JS 1.0.0
 * Use Case: Multi-room chat with user authentication and content moderation
 */

/**
 * Handle message publishing to chat channels
 *
 * Event Structure:
 * {
 *   data: {
 *     message: string,
 *     type: "text" | "image" | "file",
 *     replyTo: string (optional)
 *   }
 * }
 *
 * @param {Object} ctx - Context object
 * @param {Object} ctx.args - Publish arguments
 * @param {Object} ctx.args.data - Message data
 * @param {Object} ctx.identity - Publisher identity
 * @param {Object} ctx.info - Channel information
 * @returns {Object} Response with action and optionally transformed data
 */
export function onPublish(ctx) {
  const { data } = ctx.args;
  const { identity, info } = ctx;

  // Extract channel information
  // Example channel: /chat/room-123
  const channelParts = info.channelName.split('/');
  const roomId = channelParts[channelParts.length - 1];

  console.log(`[CHAT] Publish attempt by ${identity.sub} to room ${roomId}`);

  // 1. Authorization: Check if user is member of this chat room
  if (!isUserInRoom(identity, roomId)) {
    console.warn(`[CHAT] User ${identity.sub} not authorized for room ${roomId}`);
    return {
      action: "DENY",
      reason: "You must be a member of this chat room to send messages"
    };
  }

  // 2. Rate Limiting: Prevent spam
  if (isRateLimited(identity.sub, roomId)) {
    console.warn(`[CHAT] Rate limit exceeded for user ${identity.sub}`);
    return {
      action: "DENY",
      reason: "You are sending messages too quickly. Please slow down."
    };
  }

  // 3. Content Validation: Check message structure
  if (!data.message || typeof data.message !== 'string') {
    return {
      action: "DENY",
      reason: "Message content is required and must be a string"
    };
  }

  // 4. Content Moderation: Filter inappropriate content
  if (containsProfanity(data.message)) {
    console.warn(`[CHAT] Profanity detected in message from ${identity.sub}`);
    return {
      action: "DENY",
      reason: "Message contains inappropriate content"
    };
  }

  // 5. Size Validation: Enforce message limits
  const maxLength = data.type === 'text' ? 2000 : 500; // URLs can be shorter
  if (data.message.length > maxLength) {
    return {
      action: "DENY",
      reason: `Message exceeds maximum length of ${maxLength} characters`
    };
  }

  // 6. Data Transformation: Enrich message with metadata
  const enrichedMessage = {
    ...data,
    messageId: generateMessageId(),
    userId: identity.sub,
    username: identity.username || identity.email?.split('@')[0] || 'Anonymous',
    roomId: roomId,
    timestamp: new Date().toISOString(),
    edited: false
  };

  // 7. Success: Allow publication with enriched data
  console.log(`[CHAT] Message ${enrichedMessage.messageId} published successfully`);
  return {
    action: "ALLOW",
    data: enrichedMessage
  };
}

/**
 * Handle subscription requests to chat channels
 *
 * @param {Object} ctx - Context object
 * @param {string} ctx.args.channelName - Channel name being subscribed to
 * @param {Object} ctx.identity - Subscriber identity
 * @param {Object} ctx.info - Channel information
 * @returns {Object} Response with action
 */
export function onSubscribe(ctx) {
  const { channelName } = ctx.args;
  const { identity, info } = ctx;

  // Extract room ID from channel name
  // Example channel: /chat/room-123
  const channelParts = channelName.split('/');
  const roomId = channelParts[channelParts.length - 1];

  console.log(`[CHAT] Subscribe attempt by ${identity.sub} to room ${roomId}`);

  // 1. Authentication Check: Ensure user is logged in
  if (!identity.sub && !identity.username) {
    console.warn(`[CHAT] Unauthenticated subscription attempt to room ${roomId}`);
    return {
      action: "DENY",
      reason: "You must be logged in to join chat rooms"
    };
  }

  // 2. Authorization: Check room membership
  if (!isUserInRoom(identity, roomId)) {
    console.warn(`[CHAT] User ${identity.sub} not member of room ${roomId}`);
    return {
      action: "DENY",
      reason: "You must be invited to this chat room"
    };
  }

  // 3. Concurrent Connection Limit
  const activeConnections = getUserConnectionCount(identity.sub);
  if (activeConnections >= 5) {
    console.warn(`[CHAT] Connection limit reached for user ${identity.sub}`);
    return {
      action: "DENY",
      reason: "Maximum concurrent chat connections reached (5)"
    };
  }

  // 4. Private Room Check
  if (isPrivateRoom(roomId) && !hasPrivateAccess(identity, roomId)) {
    console.warn(`[CHAT] Private room access denied for ${identity.sub}`);
    return {
      action: "DENY",
      reason: "This is a private chat room"
    };
  }

  // 5. Success: Allow subscription
  console.log(`[CHAT] User ${identity.sub} subscribed to room ${roomId}`);
  return {
    action: "ALLOW"
  };
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
  const bannedWords = ['spam', 'badword1', 'badword2'];
  const lowerMessage = message.toLowerCase();
  return bannedWords.some(word => lowerMessage.includes(word));
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
  return roomId.startsWith('private-');
}

/**
 * Check if user has private room access
 */
function hasPrivateAccess(identity, roomId) {
  // In production: Check permissions table
  // For demo: Admins have access
  const userRoles = identity.claims?.['cognito:groups'] || [];
  return userRoles.includes('admin') || userRoles.includes('moderator');
}
