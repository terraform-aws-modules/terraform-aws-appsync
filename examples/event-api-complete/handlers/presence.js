/**
 * Presence Channel Handler
 *
 * This handler manages user presence tracking (online/offline/away status).
 * It demonstrates status updates, heartbeat management, and presence broadcasting.
 *
 * Runtime: APPSYNC_JS 1.0.0
 * Use Case: Real-time user presence in applications (online indicators, typing status)
 */

/**
 * Handle presence status publishing
 *
 * Event Structure:
 * {
 *   data: {
 *     status: "online" | "offline" | "away" | "busy",
 *     activity: string (optional - "typing", "viewing", etc.),
 *     customStatus: string (optional),
 *     lastSeen: string (ISO timestamp, optional)
 *   }
 * }
 *
 * @param {Object} ctx - Context object
 * @returns {Object} Response with action and data
 */
export function onPublish(ctx) {
  const { data } = ctx.args;
  const { identity, info } = ctx;

  // Extract context from channel name
  // Examples:
  // /presence/global - Global presence
  // /presence/room-123 - Room-specific presence
  const channelParts = info.channelName.split('/');
  const context = channelParts[channelParts.length - 1];

  console.log(`[PRESENCE] Status update from ${identity.sub} in context ${context}`);

  // 1. Validation: Status is required
  if (!data.status) {
    return {
      action: "DENY",
      reason: "Status field is required"
    };
  }

  // 2. Validation: Status must be valid
  const validStatuses = ['online', 'offline', 'away', 'busy'];
  if (!validStatuses.includes(data.status)) {
    return {
      action: "DENY",
      reason: `Invalid status. Must be one of: ${validStatuses.join(', ')}`
    };
  }

  // 3. Rate Limiting: Prevent presence spam
  // Users shouldn't update presence more than once per second
  if (isPresenceRateLimited(identity.sub, context)) {
    console.warn(`[PRESENCE] Rate limit exceeded for user ${identity.sub}`);
    return {
      action: "DENY",
      reason: "Presence updates too frequent. Max 1 per second."
    };
  }

  // 4. Privacy Check: User has privacy mode enabled
  if (hasPrivacyModeEnabled(identity.sub) && data.status !== 'offline') {
    console.log(`[PRESENCE] User ${identity.sub} has privacy mode enabled`);
    // Override status to offline for privacy
    data.status = 'offline';
    data.activity = null;
    data.customStatus = null;
  }

  // 5. Context Authorization: Check if user is allowed in this context
  if (context !== 'global' && !isUserAllowedInContext(identity, context)) {
    console.warn(`[PRESENCE] User ${identity.sub} not authorized for context ${context}`);
    return {
      action: "DENY",
      reason: "You are not authorized to broadcast presence in this context"
    };
  }

  // 6. Custom Status Validation
  if (data.customStatus && data.customStatus.length > 100) {
    return {
      action: "DENY",
      reason: "Custom status must be 100 characters or less"
    };
  }

  // 7. Enrich presence data
  const enrichedPresence = {
    userId: identity.sub,
    username: identity.username || identity.email?.split('@')[0] || 'Anonymous',
    status: data.status,
    activity: data.activity || null,
    customStatus: data.customStatus || null,
    lastSeen: data.lastSeen || new Date().toISOString(),
    context: context,
    timestamp: new Date().toISOString()
  };

  // 8. Store presence (for offline tracking)
  storePresenceUpdate(enrichedPresence);

  console.log(`[PRESENCE] User ${identity.sub} status: ${data.status} in ${context}`);
  return {
    action: "ALLOW",
    data: enrichedPresence
  };
}

/**
 * Handle presence subscription requests
 *
 * @param {Object} ctx - Context object
 * @returns {Object} Response with action
 */
export function onSubscribe(ctx) {
  const { channelName } = ctx.args;
  const { identity } = ctx;

  // Extract context from channel name
  const channelParts = channelName.split('/');
  const context = channelParts[channelParts.length - 1];

  console.log(`[PRESENCE] Subscribe attempt by ${identity.sub} to presence in ${context}`);

  // 1. Authentication required
  if (!identity.sub && !identity.username) {
    return {
      action: "DENY",
      reason: "Authentication required to view presence information"
    };
  }

  // 2. Context Authorization
  if (context !== 'global' && !isUserAllowedInContext(identity, context)) {
    console.warn(`[PRESENCE] User ${identity.sub} not authorized for presence context ${context}`);
    return {
      action: "DENY",
      reason: "You are not authorized to view presence in this context"
    };
  }

  // 3. Privacy Settings: Check if user allows presence visibility
  if (context === 'global' && !allowsGlobalPresence(identity.sub)) {
    console.log(`[PRESENCE] User ${identity.sub} has global presence disabled`);
    return {
      action: "DENY",
      reason: "You have disabled global presence visibility in settings"
    };
  }

  // 4. Concurrent Subscription Limit
  const activePresenceSubscriptions = getUserPresenceSubscriptionCount(identity.sub);
  if (activePresenceSubscriptions >= 20) {
    console.warn(`[PRESENCE] Subscription limit reached for user ${identity.sub}`);
    return {
      action: "DENY",
      reason: "Maximum presence subscriptions reached (20)"
    };
  }

  // 5. Send initial presence snapshot
  // Note: This would typically trigger a separate mechanism to send
  // current presence state of all users in the context
  console.log(`[PRESENCE] User ${identity.sub} subscribed to presence in ${context}`);

  return {
    action: "ALLOW"
  };
}

// ========================================
// Helper Functions
// ========================================

/**
 * Check if presence updates are rate limited
 */
function isPresenceRateLimited(userId, context) {
  // In production: Use Redis with sliding window
  // Max 1 update per second per context
  return false;
}

/**
 * Check if user has privacy mode enabled
 */
function hasPrivacyModeEnabled(userId) {
  // In production: Query user settings from DynamoDB
  // Privacy mode hides online status
  return false;
}

/**
 * Check if user is allowed to broadcast presence in context
 */
function isUserAllowedInContext(identity, context) {
  // For room contexts, check if user is member
  // Example: context = "room-123"
  if (context.startsWith('room-')) {
    // In production: Check room membership
    return true;
  }

  // For global context, all authenticated users allowed
  if (context === 'global') {
    return true;
  }

  // For other contexts, check specific permissions
  return true;
}

/**
 * Store presence update for offline tracking
 */
function storePresenceUpdate(presenceData) {
  // In production: Write to DynamoDB with TTL
  // Example:
  // await ddb.put({
  //   TableName: 'UserPresence',
  //   Item: {
  //     userId: presenceData.userId,
  //     context: presenceData.context,
  //     status: presenceData.status,
  //     lastSeen: presenceData.timestamp,
  //     ttl: Math.floor(Date.now() / 1000) + 86400 // 24 hour TTL
  //   }
  // });

  console.log(`[PRESENCE] Stored presence update for user ${presenceData.userId}`);
}

/**
 * Check if user allows global presence visibility
 */
function allowsGlobalPresence(userId) {
  // In production: Query user privacy settings
  // Some users may want to hide presence globally
  return true;
}

/**
 * Get user's active presence subscription count
 */
function getUserPresenceSubscriptionCount(userId) {
  // In production: Track active subscriptions per user
  // Limit to prevent resource exhaustion
  return 1;
}
