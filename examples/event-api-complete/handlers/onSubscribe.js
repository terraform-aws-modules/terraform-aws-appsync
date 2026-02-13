/**
 * AppSync Event API - onSubscribe Handler Example
 *
 * This handler is invoked when a client subscribes to a channel.
 * It can authorize subscription requests and filter which channels users can access.
 *
 * Runtime: APPSYNC_JS 1.0.0
 *
 * To deny a subscription, call util.unauthorize() which returns a subscribe_error
 * with an Unauthorized error type (HTTP 401 for HTTP connections).
 * To allow a subscription, simply return normally (return null or undefined).
 *
 * @see https://docs.aws.amazon.com/appsync/latest/eventapi/writing-event-handlers.html
 */

/**
 * Handler function for subscribe events
 *
 * @param {Object} ctx - Context object containing event information
 * @param {Object} ctx.args - Arguments passed to the subscribe operation
 * @param {string} ctx.args.channelName - Name of the channel being subscribed to
 * @param {Object} ctx.identity - Identity of the subscriber
 * @param {Object} ctx.info - Channel and namespace information
 */
export function onSubscribe(ctx) {
  const { channelName } = ctx.args;
  const { identity, info } = ctx;

  // Example 1: Authorization - Check if user can subscribe to this channel
  if (!canSubscribe(identity, info.channelNamespace, channelName)) {
    util.unauthorize();
    return;
  }

  // Example 2: Rate Limiting - Limit concurrent subscriptions per user
  const userSubscriptions = getUserSubscriptionCount(identity);
  if (userSubscriptions >= 10) {
    util.unauthorize();
    return;
  }

  // Example 3: Channel Pattern Filtering - Block subscription to admin channels
  if (isAdminChannel(channelName) && !isAdmin(identity)) {
    util.unauthorize();
    return;
  }

  // Example 4: Geographic Restrictions - Check region-based access
  const userRegion = identity.claims?.region;
  if (requiresRegionAccess(channelName, userRegion)) {
    util.unauthorize();
    return;
  }

  // Subscription allowed - return null to permit
  return null;
}

/**
 * Check if the identity can subscribe to the channel
 * @param {Object} identity - User identity
 * @param {string} namespace - Channel namespace
 * @param {string} channelName - Channel name
 * @returns {boolean} True if subscription is allowed
 */
function canSubscribe(identity, namespace, channelName) {
  // Example: Check user authentication status
  if (!identity.sub && !identity.username) {
    return false; // Unauthenticated users cannot subscribe
  }

  // Example: Check user subscription tier
  const subscriptionTier = identity.claims?.tier || "free";

  // Premium channels require premium tier
  if (channelName.startsWith("premium-") && subscriptionTier !== "premium") {
    return false;
  }

  return true;
}

/**
 * Get the current subscription count for a user (stub)
 * In production, this would query a DynamoDB table or cache
 * @param {Object} identity - User identity
 * @returns {number} Number of active subscriptions
 */
function getUserSubscriptionCount(identity) {
  // Stub: In real implementation, query subscription tracking system
  // For example purposes, return a mock value
  return 0;
}

/**
 * Check if a channel is an admin channel
 * @param {string} channelName - Channel name
 * @returns {boolean} True if admin channel
 */
function isAdminChannel(channelName) {
  return (
    channelName.startsWith("admin-") ||
    channelName.includes("-internal") ||
    channelName === "system-events"
  );
}

/**
 * Check if the identity has admin role
 * @param {Object} identity - User identity
 * @returns {boolean} True if user is admin
 */
function isAdmin(identity) {
  const userRoles = identity.claims?.["cognito:groups"] || [];
  return userRoles.includes("admin") || userRoles.includes("moderator");
}

/**
 * Check if channel requires region-based access
 * @param {string} channelName - Channel name
 * @param {string} userRegion - User's region
 * @returns {boolean} True if region restriction applies
 */
function requiresRegionAccess(channelName, userRegion) {
  // Example: Regional channels for compliance (GDPR, data residency)
  const regionalChannels = {
    "eu-only": ["eu-west-1", "eu-central-1"],
    "us-only": ["us-east-1", "us-west-2"],
  };

  for (const [prefix, allowedRegions] of Object.entries(regionalChannels)) {
    if (channelName.startsWith(prefix)) {
      return !allowedRegions.includes(userRegion);
    }
  }

  return false;
}
