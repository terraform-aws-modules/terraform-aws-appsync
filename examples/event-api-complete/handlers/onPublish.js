/**
 * AppSync Event API - onPublish Handler Example
 *
 * This handler is invoked when a message is published to a channel.
 * It can filter, transform, or authorize publish operations.
 *
 * Runtime: APPSYNC_JS 1.0.0
 */

/**
 * Main handler function for publish events
 *
 * @param {Object} ctx - Context object containing event information
 * @param {Object} ctx.args - Arguments passed to the publish operation
 * @param {Object} ctx.args.data - The message data being published
 * @param {Object} ctx.identity - Identity of the publisher
 * @param {Object} ctx.info - Channel and namespace information
 * @returns {Object} Response with action (ALLOW or DENY) and optional modified data
 */
export function handler(ctx) {
  const { data } = ctx.args;
  const { identity, info } = ctx;

  // Example 1: Authorization - Check if user can publish to this channel
  if (!isAuthorized(identity, info.channelNamespace, info.channelName)) {
    return {
      action: "DENY",
      reason: "User not authorized to publish to this channel"
    };
  }

  // Example 2: Content Filtering - Block messages with inappropriate content
  if (containsInappropriateContent(data)) {
    return {
      action: "DENY",
      reason: "Message contains inappropriate content"
    };
  }

  // Example 3: Data Transformation - Enrich message with metadata
  const enrichedData = {
    ...data,
    publishedAt: new Date().toISOString(),
    publishedBy: identity.sub || identity.username,
    channelInfo: {
      namespace: info.channelNamespace,
      channel: info.channelName
    }
  };

  // Example 4: Size Validation - Enforce message size limits
  const messageSize = JSON.stringify(enrichedData).length;
  if (messageSize > 32768) { // 32 KB limit
    return {
      action: "DENY",
      reason: "Message size exceeds 32 KB limit"
    };
  }

  // Allow the publish operation with transformed data
  return {
    action: "ALLOW",
    data: enrichedData
  };
}

/**
 * Check if the identity is authorized to publish
 * @param {Object} identity - User identity
 * @param {string} namespace - Channel namespace
 * @param {string} channel - Channel name
 * @returns {boolean} True if authorized
 */
function isAuthorized(identity, namespace, channel) {
  // Example: Check user roles or permissions
  const userRoles = identity.claims?.["cognito:groups"] || [];

  // Allow admins to publish anywhere
  if (userRoles.includes("admin")) {
    return true;
  }

  // Check channel-specific permissions
  if (channel.startsWith("private-") && !userRoles.includes("premium")) {
    return false;
  }

  return true;
}

/**
 * Check if data contains inappropriate content
 * @param {Object} data - Message data
 * @returns {boolean} True if inappropriate content detected
 */
function containsInappropriateContent(data) {
  // Example: Simple content filtering
  const bannedWords = ["spam", "abuse"];
  const messageText = JSON.stringify(data).toLowerCase();

  return bannedWords.some(word => messageText.includes(word));
}
