/**
 * Notifications Channel Handler
 *
 * This handler manages notification delivery for users.
 * It demonstrates targeting, priority filtering, and delivery optimization.
 *
 * Runtime: APPSYNC_JS 1.0.0
 * Use Case: User notifications with priority levels and read receipts
 */

/**
 * Handle notification publishing
 *
 * Event Structure:
 * {
 *   data: {
 *     title: string,
 *     body: string,
 *     priority: "low" | "normal" | "high" | "urgent",
 *     category: string,
 *     actionUrl: string (optional),
 *     expiresAt: string (ISO timestamp, optional)
 *   }
 * }
 *
 * @param {Object} ctx - Context object
 * @returns {Object} Response with action and data
 */
export function onPublish(ctx) {
  const { data } = ctx.args;
  const { identity, info } = ctx;

  // Extract target user from channel name
  // Example channel: /notifications/user-123
  const channelParts = info.channelName.split('/');
  const targetUserId = channelParts[channelParts.length - 1].replace('user-', '');

  console.log(`[NOTIFICATIONS] Publishing to user ${targetUserId} from ${identity.sub}`);

  // 1. Authorization: Only system or admin can publish notifications
  if (!isAuthorizedPublisher(identity)) {
    console.warn(`[NOTIFICATIONS] Unauthorized publish attempt by ${identity.sub}`);
    return {
      action: "DENY",
      reason: "Only system administrators can send notifications"
    };
  }

  // 2. Validation: Required fields
  if (!data.title || !data.body) {
    return {
      action: "DENY",
      reason: "Notification must have title and body"
    };
  }

  // 3. Priority Validation
  const validPriorities = ['low', 'normal', 'high', 'urgent'];
  const priority = data.priority || 'normal';
  if (!validPriorities.includes(priority)) {
    return {
      action: "DENY",
      reason: `Invalid priority. Must be one of: ${validPriorities.join(', ')}`
    };
  }

  // 4. Rate Limiting: Prevent notification spam
  if (isNotificationRateLimited(targetUserId)) {
    console.warn(`[NOTIFICATIONS] Rate limit exceeded for user ${targetUserId}`);
    // For urgent notifications, allow anyway
    if (priority !== 'urgent') {
      return {
        action: "DENY",
        reason: "Notification rate limit exceeded"
      };
    }
  }

  // 5. Content Length Validation
  if (data.title.length > 100 || data.body.length > 500) {
    return {
      action: "DENY",
      reason: "Title max 100 chars, body max 500 chars"
    };
  }

  // 6. User Preferences: Check if user allows this category
  if (!userAllowsNotificationCategory(targetUserId, data.category)) {
    console.log(`[NOTIFICATIONS] User ${targetUserId} has disabled ${data.category} notifications`);
    // Silently drop (don't send DENY to publisher)
    return {
      action: "ALLOW",
      data: {
        ...data,
        dropped: true,
        dropReason: "User preferences"
      }
    };
  }

  // 7. Expiration Check
  if (data.expiresAt) {
    const expiresAt = new Date(data.expiresAt);
    if (expiresAt < new Date()) {
      console.log(`[NOTIFICATIONS] Notification expired, not sending`);
      return {
        action: "ALLOW",
        data: {
          ...data,
          dropped: true,
          dropReason: "Expired"
        }
      };
    }
  }

  // 8. Enrich notification with metadata
  const enrichedNotification = {
    ...data,
    notificationId: generateNotificationId(),
    targetUserId: targetUserId,
    senderId: identity.sub,
    timestamp: new Date().toISOString(),
    priority: priority,
    read: false,
    delivered: true
  };

  console.log(`[NOTIFICATIONS] Notification ${enrichedNotification.notificationId} sent to user ${targetUserId}`);
  return {
    action: "ALLOW",
    data: enrichedNotification
  };
}

/**
 * Handle notification subscription requests
 *
 * @param {Object} ctx - Context object
 * @returns {Object} Response with action
 */
export function onSubscribe(ctx) {
  const { channelName } = ctx.args;
  const { identity } = ctx;

  // Extract target user from channel name
  const channelParts = channelName.split('/');
  const targetUserId = channelParts[channelParts.length - 1].replace('user-', '');

  console.log(`[NOTIFICATIONS] Subscribe attempt by ${identity.sub} to notifications for user ${targetUserId}`);

  // 1. Authentication required
  if (!identity.sub && !identity.username) {
    return {
      action: "DENY",
      reason: "Authentication required to receive notifications"
    };
  }

  // 2. Authorization: Users can only subscribe to their own notifications
  if (identity.sub !== targetUserId && !isAdmin(identity)) {
    console.warn(`[NOTIFICATIONS] User ${identity.sub} attempted to subscribe to ${targetUserId}'s notifications`);
    return {
      action: "DENY",
      reason: "You can only subscribe to your own notifications"
    };
  }

  // 3. Device Limit Check
  const activeDevices = getUserDeviceCount(identity.sub);
  if (activeDevices >= 10) {
    console.warn(`[NOTIFICATIONS] Device limit reached for user ${identity.sub}`);
    return {
      action: "DENY",
      reason: "Maximum notification devices reached (10)"
    };
  }

  // 4. Subscription Preferences Check
  if (!userHasNotificationsEnabled(targetUserId)) {
    console.log(`[NOTIFICATIONS] User ${targetUserId} has notifications disabled`);
    return {
      action: "DENY",
      reason: "Notifications are disabled in your account settings"
    };
  }

  console.log(`[NOTIFICATIONS] User ${identity.sub} subscribed to notifications`);
  return {
    action: "ALLOW"
  };
}

// ========================================
// Helper Functions
// ========================================

/**
 * Check if identity is authorized to publish notifications
 */
function isAuthorizedPublisher(identity) {
  // Check for system role or admin role
  const roles = identity.claims?.['cognito:groups'] || [];
  return roles.includes('admin') || roles.includes('system') || roles.includes('notification-service');
}

/**
 * Check if user is being rate limited for notifications
 */
function isNotificationRateLimited(userId) {
  // In production: Check Redis/DynamoDB for notification count in time window
  // Example: Max 50 notifications per hour
  return false;
}

/**
 * Check if user allows notifications for this category
 */
function userAllowsNotificationCategory(userId, category) {
  // In production: Query user preferences from DynamoDB
  // Categories: mentions, messages, updates, marketing, system
  // For demo: Allow all except if explicitly set
  return true;
}

/**
 * Generate unique notification ID
 */
function generateNotificationId() {
  return `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Check if user is admin
 */
function isAdmin(identity) {
  const roles = identity.claims?.['cognito:groups'] || [];
  return roles.includes('admin');
}

/**
 * Get user's active device count
 */
function getUserDeviceCount(userId) {
  // In production: Track active WebSocket connections per user
  return 1;
}

/**
 * Check if user has notifications enabled
 */
function userHasNotificationsEnabled(userId) {
  // In production: Check user settings in DynamoDB
  return true;
}
