# AppSync Event API - JavaScript Handler Examples

This directory contains JavaScript handler examples for AWS AppSync Event API channel namespaces. These handlers demonstrate real-world use cases with filtering, transformation, authorization, and error handling patterns.

## Handler Overview

| Handler | Use Case | Features |
|---------|----------|----------|
| **chat.js** | Real-time chat application | Content moderation, rate limiting, room authorization |
| **notifications.js** | User notification system | Priority filtering, user preferences, delivery optimization |
| **presence.js** | User presence tracking | Status updates, privacy controls, heartbeat management |
| **onPublish.js** | Generic publish handler | Template for custom publish logic |
| **onSubscribe.js** | Generic subscribe handler | Template for custom subscribe logic |

## Runtime Environment

- **Runtime:** `APPSYNC_JS 1.0.0`
- **Language:** JavaScript (ES6+)
- **Execution:** Serverless, stateless functions
- **Timeout:** 30 seconds max

## Handler Structure

Each handler must export two functions:

```javascript
/**
 * Handles publish events (when messages are sent to channel)
 * @param {Object} ctx - Context object
 * @returns {Object} Response with action (ALLOW or DENY) and optional data
 */
export function onPublish(ctx) {
  // Your logic here
  return {
    action: "ALLOW",  // or "DENY"
    data: transformedData  // optional
  };
}

/**
 * Handles subscribe events (when clients subscribe to channel)
 * @param {Object} ctx - Context object
 * @returns {Object} Response with action (ALLOW or DENY)
 */
export function onSubscribe(ctx) {
  // Your logic here
  return {
    action: "ALLOW"  // or "DENY"
  };
}
```

## Context Object Structure

The `ctx` parameter provides event information:

```javascript
{
  args: {
    // For onPublish
    data: { /* message data */ },

    // For onSubscribe
    channelName: "/namespace/channel-name"
  },

  identity: {
    sub: "user-id",
    username: "username",
    email: "user@example.com",
    claims: {
      "cognito:groups": ["admin", "user"],
      // ... other JWT claims
    }
  },

  info: {
    channelNamespace: "namespace",
    channelName: "/namespace/channel-name"
  }
}
```

## Response Formats

### Allow Action

```javascript
return {
  action: "ALLOW",
  data: {  // optional for onPublish only
    message: "transformed message",
    metadata: { ... }
  }
};
```

### Deny Action

```javascript
return {
  action: "DENY",
  reason: "User not authorized"  // optional but recommended
};
```

## Use Case Examples

### 1. Chat Application (`chat.js`)

**Features:**
- ✅ Room membership verification
- ✅ Rate limiting (prevent spam)
- ✅ Content moderation (profanity filtering)
- ✅ Message size validation
- ✅ Data enrichment (timestamps, user info)
- ✅ Private room access control

**Event Structure:**
```javascript
{
  message: "Hello world",
  type: "text",  // "text" | "image" | "file"
  replyTo: "msg_123"  // optional
}
```

**Key Functions:**
- `onPublish()` - Validates and enriches chat messages
- `onSubscribe()` - Authorizes room access
- `isUserInRoom()` - Checks room membership
- `containsProfanity()` - Content moderation
- `isRateLimited()` - Spam prevention

**Usage:**
```hcl
channel_namespaces = {
  "chat" = {
    code_handlers = file("${path.module}/handlers/chat.js")
  }
}
```

**Channels:**
- `/chat/room-123` - Specific chat room
- `/chat/general` - General chat channel
- `/chat/private-456` - Private chat room

---

### 2. Notification System (`notifications.js`)

**Features:**
- ✅ Priority levels (low, normal, high, urgent)
- ✅ User preference filtering
- ✅ Notification expiration
- ✅ Rate limiting per user
- ✅ Category-based filtering
- ✅ Device limit enforcement

**Event Structure:**
```javascript
{
  title: "New Message",
  body: "You have a new message from John",
  priority: "high",  // "low" | "normal" | "high" | "urgent"
  category: "messages",  // mentions, updates, marketing, system
  actionUrl: "https://app.example.com/messages/123",
  expiresAt: "2024-12-31T23:59:59Z"
}
```

**Key Functions:**
- `onPublish()` - Validates and routes notifications
- `onSubscribe()` - Authorizes notification access
- `isAuthorizedPublisher()` - Publisher authorization
- `userAllowsNotificationCategory()` - User preferences
- `isNotificationRateLimited()` - Rate limiting

**Usage:**
```hcl
channel_namespaces = {
  "notifications" = {
    code_handlers = file("${path.module}/handlers/notifications.js")
  }
}
```

**Channels:**
- `/notifications/user-123` - User-specific notifications
- `/notifications/broadcast` - System-wide announcements

---

### 3. Presence Tracking (`presence.js`)

**Features:**
- ✅ Status updates (online, offline, away, busy)
- ✅ Activity tracking (typing, viewing)
- ✅ Privacy mode support
- ✅ Custom status messages
- ✅ Context-based presence (global, room-specific)
- ✅ Heartbeat management

**Event Structure:**
```javascript
{
  status: "online",  // "online" | "offline" | "away" | "busy"
  activity: "typing",  // optional
  customStatus: "Working from home",  // optional
  lastSeen: "2024-01-15T10:30:00Z"
}
```

**Key Functions:**
- `onPublish()` - Updates and broadcasts presence
- `onSubscribe()` - Authorizes presence visibility
- `hasPrivacyModeEnabled()` - Privacy controls
- `isPresenceRateLimited()` - Update frequency limits
- `storePresenceUpdate()` - Persistence for offline tracking

**Usage:**
```hcl
channel_namespaces = {
  "presence" = {
    code_handlers = file("${path.module}/handlers/presence.js")
  }
}
```

**Channels:**
- `/presence/global` - Global user presence
- `/presence/room-123` - Room-specific presence

---

## Common Patterns

### 1. Authorization Pattern

```javascript
export function onSubscribe(ctx) {
  const { identity } = ctx;

  // Check authentication
  if (!identity.sub) {
    return {
      action: "DENY",
      reason: "Authentication required"
    };
  }

  // Check authorization
  if (!hasPermission(identity, ctx.args.channelName)) {
    return {
      action: "DENY",
      reason: "Access denied"
    };
  }

  return { action: "ALLOW" };
}
```

### 2. Data Transformation Pattern

```javascript
export function onPublish(ctx) {
  const { data } = ctx.args;
  const { identity } = ctx;

  // Validate input
  if (!data.message) {
    return {
      action: "DENY",
      reason: "Message required"
    };
  }

  // Transform and enrich
  const enrichedData = {
    ...data,
    userId: identity.sub,
    timestamp: new Date().toISOString(),
    messageId: generateId()
  };

  return {
    action: "ALLOW",
    data: enrichedData
  };
}
```

### 3. Rate Limiting Pattern

```javascript
export function onPublish(ctx) {
  const { identity } = ctx;

  // Check rate limit (implement with Redis/DynamoDB)
  if (isRateLimited(identity.sub)) {
    return {
      action: "DENY",
      reason: "Rate limit exceeded"
    };
  }

  return { action: "ALLOW", data: ctx.args.data };
}
```

### 4. Content Filtering Pattern

```javascript
export function onPublish(ctx) {
  const { data } = ctx.args;

  // Filter inappropriate content
  if (containsInappropriateContent(data)) {
    return {
      action: "DENY",
      reason: "Content violates guidelines"
    };
  }

  return { action: "ALLOW", data };
}
```

### 5. Privacy Pattern

```javascript
export function onSubscribe(ctx) {
  const { channelName } = ctx.args;
  const { identity } = ctx;

  // Extract target user from channel
  const targetUserId = extractUserId(channelName);

  // Users can only subscribe to their own private channels
  if (targetUserId !== identity.sub) {
    return {
      action: "DENY",
      reason: "Access denied"
    };
  }

  return { action: "ALLOW" };
}
```

## Error Handling

Handlers should handle errors gracefully:

```javascript
export function onPublish(ctx) {
  try {
    // Your logic here
    const result = processMessage(ctx.args.data);

    return {
      action: "ALLOW",
      data: result
    };
  } catch (error) {
    // Log error for debugging
    console.error(`[ERROR] ${error.message}`, error);

    // Return DENY with generic message (don't expose internal errors)
    return {
      action: "DENY",
      reason: "An error occurred processing your request"
    };
  }
}
```

## Logging Best Practices

Use structured logging for observability:

```javascript
export function onPublish(ctx) {
  const { identity, info } = ctx;

  // Log with context
  console.log(`[${info.channelNamespace}] Publish from ${identity.sub}`);

  // Log warnings
  console.warn(`[WARN] Rate limit approaching for ${identity.sub}`);

  // Log errors
  console.error(`[ERROR] Failed to process message`, { error, context });

  return { action: "ALLOW", data: ctx.args.data };
}
```

## Testing Handlers

Test handlers using the AppSync Event API console or wscat:

```bash
# Subscribe to channel
wscat -c "wss://your-event-api.appsync-api.us-east-1.amazonaws.com" \
  -H "x-api-key: YOUR_API_KEY"

# After connection
{"action":"subscribe","channel":"/chat/general"}

# Publish message
{"action":"publish","channel":"/chat/general","events":["Hello World"]}
```

## Performance Considerations

1. **Keep handlers lightweight** - Complex logic should use Lambda datasources
2. **Avoid external API calls** - Use Lambda for external integrations
3. **Minimize computation** - Handlers have 30-second timeout
4. **Use efficient data structures** - Avoid deep nesting
5. **Cache frequently accessed data** - Use in-memory caching where possible

## Security Best Practices

1. **Always validate input** - Never trust client data
2. **Sanitize output** - Prevent XSS attacks
3. **Implement authorization** - Check permissions on every action
4. **Rate limit aggressively** - Prevent abuse and DoS
5. **Log security events** - Monitor suspicious activity
6. **Use least privilege** - Grant minimum necessary permissions
7. **Encrypt sensitive data** - Use KMS for encryption
8. **Validate JWT claims** - Check token expiration and issuer

## Limitations

- **Stateless execution** - No shared state between invocations
- **30-second timeout** - Long operations need Lambda datasources
- **No external dependencies** - Cannot import npm packages
- **Read-only data** - Cannot modify DynamoDB directly (use Lambda)
- **No async/await** - Use Lambda for async operations

## Further Reading

- [AWS AppSync Event API Documentation](https://docs.aws.amazon.com/appsync/latest/eventapi/)
- [JavaScript Handler Runtime](https://docs.aws.amazon.com/appsync/latest/eventapi/resolver-reference-overview-js.html)
- [Event API Channel Namespaces](https://docs.aws.amazon.com/appsync/latest/eventapi/event-api-channel-namespace.html)
- [Module README](../../README.md)

## License

Apache 2 Licensed. See LICENSE for full details.
