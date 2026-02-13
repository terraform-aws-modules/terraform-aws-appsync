/**
 * AppSync Event API - onPublish Handler Example
 *
 * This handler is invoked when events are published to a channel.
 * It can filter, transform, or reject publish operations.
 *
 * The handler receives ctx.events (an array of events) and must return
 * the events array (modified or filtered) or call util.error() to reject.
 *
 * Runtime: APPSYNC_JS 1.0.0
 *
 * @see https://docs.aws.amazon.com/appsync/latest/eventapi/channel-namespace-handlers.html
 */

import { util } from "@aws-appsync/utils";

/**
 * onPublish handler for Event API publish operations
 *
 * @param {Object} ctx - Context object containing event information
 * @param {Array} ctx.events - Array of events being published, each with { id, payload }
 * @param {Object} ctx.identity - Identity of the publisher
 * @param {Object} ctx.info - Channel and namespace information
 * @param {Object} ctx.channelNamespace - Channel namespace details
 * @returns {Array} Processed events array to broadcast to subscribers
 */
export function onPublish(ctx) {
  const { events, identity, info, channelNamespace } = ctx;

  // Example 1: Authorization - Reject entire publish if user is not authorized
  if (!isAuthorized(identity, channelNamespace.name, info.channel.path)) {
    util.error("User not authorized to publish to this channel");
  }

  // Example 2: Process each event - filter, transform, and validate
  return events.map((event) => {
    // Content Filtering - Mark events with inappropriate content as errors
    if (containsInappropriateContent(event.payload)) {
      return {
        id: event.id,
        error: "Message contains inappropriate content",
      };
    }

    // Size Validation - Enforce message size limits
    const messageSize = JSON.stringify(event.payload).length;
    if (messageSize > 32768) {
      // 32 KB limit
      return {
        id: event.id,
        error: "Message size exceeds 32 KB limit",
      };
    }

    // Data Transformation - Enrich event payload with metadata
    return {
      id: event.id,
      payload: {
        ...event.payload,
        publishedAt: util.time.nowISO8601(),
        publishedBy: identity.sub || identity.username,
        channelInfo: {
          namespace: channelNamespace.name,
          channel: info.channel.path,
        },
      },
    };
  });
}

/**
 * Check if the identity is authorized to publish
 * @param {Object} identity - User identity
 * @param {string} namespace - Channel namespace
 * @param {string} channelPath - Full channel path
 * @returns {boolean} True if authorized
 */
function isAuthorized(identity, namespace, channelPath) {
  // Example: Check user roles or permissions
  const userRoles = identity.claims?.["cognito:groups"] || [];

  // Allow admins to publish anywhere
  if (userRoles.includes("admin")) {
    return true;
  }

  // Check channel-specific permissions
  if (channelPath.startsWith("/private") && !userRoles.includes("premium")) {
    return false;
  }

  return true;
}

/**
 * Check if data contains inappropriate content
 * @param {Object} payload - Event payload data
 * @returns {boolean} True if inappropriate content detected
 */
function containsInappropriateContent(payload) {
  // Example: Simple content filtering
  const bannedWords = ["spam", "abuse"];
  const messageText = JSON.stringify(payload).toLowerCase();

  return bannedWords.some((word) => messageText.includes(word));
}
