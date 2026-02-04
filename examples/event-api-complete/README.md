# AppSync Event API - Complete Example

This example demonstrates **all features** of the AWS AppSync Event API (WebSocket pub/sub) using this Terraform module.

## Features Demonstrated

### ✅ Authentication Types
- **API_KEY** - Simple API key authentication
- **AWS_IAM** - IAM-based authentication with SigV4
- **AWS_COGNITO_USER_POOLS** - Cognito User Pool authentication (optional)
- **OPENID_CONNECT** - OIDC provider authentication (optional)
- **AWS_LAMBDA** - Custom Lambda authorizer (optional)

### ✅ Channel Namespaces
- **chat** - Chat channels with JavaScript code handlers
- **notifications** - Notification channels with Lambda or JavaScript handlers
- **presence** - Presence tracking with JavaScript handlers

### ✅ Datasources
- **Lambda** - AWS Lambda datasource with auto-generated IAM role
- **HTTP** - HTTP endpoint datasource with IAM SigV4 signing

### ✅ CloudWatch Logs
- Logging enabled with `ALL` log level
- Auto-generated IAM role with `AWSAppSyncPushToCloudWatchLogs` policy
- Captures connection, publish, and subscribe events

### ✅ Custom Domain (Optional)
- Custom domain name association
- ACM certificate integration
- CloudFront-backed distribution

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.5.7
3. **AWS CLI** configured with credentials
4. **(Optional)** ACM certificate in `us-east-1` for custom domain
5. **(Optional)** Cognito User Pool for Cognito authentication
6. **(Optional)** Lambda function for Lambda authorizer or handlers

## Quick Start

### 1. Clone and Navigate
```bash
git clone <repository>
cd terraform-aws-appsync/examples/event-api-complete
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Deploy (Minimal Configuration)
```bash
terraform apply
```

This deploys an Event API with:
- API Key authentication
- 3 channel namespaces (chat, notifications, presence)
- JavaScript code handlers
- CloudWatch Logs
- No custom domain

### 4. Get API Key
```bash
terraform output -raw api_key
```

### 5. Test WebSocket Connection
```bash
# Install wscat (WebSocket CLI tool)
npm install -g wscat

# Connect to Event API
wscat -c "$(terraform output -raw event_api_realtime_url)" \
  -H "x-api-key: $(terraform output -raw api_key)"
```

## Advanced Configuration

### Enable Cognito Authentication
```bash
terraform apply \
  -var="cognito_user_pool_id=us-east-1_ABC123456"
```

### Enable OIDC Authentication
```bash
terraform apply \
  -var="oidc_issuer=https://accounts.google.com" \
  -var="oidc_client_id=your-client-id"
```

### Enable Lambda Authorizer
```bash
terraform apply \
  -var="lambda_authorizer_arn=arn:aws:lambda:us-east-1:123456789012:function:authorizer"
```

### Configure Custom Domain
```bash
terraform apply \
  -var="certificate_arn=arn:aws:acm:us-east-1:123456789012:certificate/abc-123" \
  -var="domain_name=ws.example.com"
```

### Full Configuration
```bash
terraform apply \
  -var="cognito_user_pool_id=us-east-1_ABC123456" \
  -var="oidc_issuer=https://accounts.google.com" \
  -var="oidc_client_id=your-client-id" \
  -var="lambda_authorizer_arn=arn:aws:lambda:us-east-1:123456789012:function:authorizer" \
  -var="chat_handler_lambda_arn=arn:aws:lambda:us-east-1:123456789012:function:chat-handler" \
  -var="certificate_arn=arn:aws:acm:us-east-1:123456789012:certificate/abc-123" \
  -var="domain_name=ws.example.com"
```

## Testing the Event API

### 1. WebSocket Connection (wscat)
```bash
# Get connection details
REALTIME_URL=$(terraform output -raw event_api_realtime_url)
API_KEY=$(terraform output -raw api_key)

# Connect
wscat -c "$REALTIME_URL" -H "x-api-key: $API_KEY"

# After connection, subscribe to channel
{"action":"subscribe","channel":"/chat/general"}

# Publish message (from another terminal)
wscat -c "$REALTIME_URL" -H "x-api-key: $API_KEY"
{"action":"publish","channel":"/chat/general","events":["Hello World"]}
```

### 2. HTTP API Publishing
```bash
HTTP_URL=$(terraform output -raw event_api_http_url)
API_KEY=$(terraform output -raw api_key)

curl -X POST "$HTTP_URL" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "/chat/general",
    "events": ["Hello from HTTP"]
  }'
```

### 3. IAM Authentication (AWS CLI)
```bash
# Create connection with IAM credentials
aws appsync-realtime connect \
  --api-id $(terraform output -raw event_api_id) \
  --region us-east-1
```

### 4. Check CloudWatch Logs
```bash
# Get log group name
EVENT_API_ID=$(terraform output -raw event_api_id)
LOG_GROUP="/aws/appsync/apis/$EVENT_API_ID"

# View recent logs
aws logs tail "$LOG_GROUP" --follow
```

## Channel Namespace Structure

### Chat Namespace (`/chat/*`)
```
/chat/general       - General chat channel
/chat/room-123      - Specific chat room
/chat/user-456      - Private user channel
```

### Notifications Namespace (`/notifications/*`)
```
/notifications/user-123    - User-specific notifications
/notifications/broadcast   - Global notifications
```

### Presence Namespace (`/presence/*`)
```
/presence/room-123    - User presence in a room
/presence/global      - Global user presence
```

## JavaScript Handlers

JavaScript handlers are located in `handlers/` directory:

- **`onPublish.js`** - Handles publish events (filtering, transformation, authorization)
- **`onSubscribe.js`** - Handles subscribe events (authorization, channel access control)

### Handler Capabilities
- ✅ Event filtering based on content
- ✅ Data transformation and enrichment
- ✅ Authorization logic
- ✅ Rate limiting
- ✅ Content moderation

See `handlers/README.md` for detailed documentation.

## Architecture Diagram

```
┌─────────────┐
│   Clients   │ (Web, Mobile, IoT)
└──────┬──────┘
       │ WebSocket (wss://) or HTTP (https://)
       │
┌──────▼────────────────────────────────────────────┐
│          AWS AppSync Event API                    │
│  ┌─────────────────────────────────────────────┐  │
│  │  Authentication Layer                       │  │
│  │  - API Key / IAM / Cognito / OIDC / Lambda  │  │
│  └─────────────────────────────────────────────┘  │
│                                                    │
│  ┌─────────────────────────────────────────────┐  │
│  │  Channel Namespaces                         │  │
│  │  - chat/*       (JavaScript handlers)       │  │
│  │  - notifications/* (Lambda handlers)        │  │
│  │  - presence/*   (JavaScript handlers)       │  │
│  └─────────────────────────────────────────────┘  │
│                                                    │
│  ┌─────────────────────────────────────────────┐  │
│  │  Datasources                                │  │
│  │  - Lambda (async processing)                │  │
│  │  - HTTP (external API integration)          │  │
│  └─────────────────────────────────────────────┘  │
└────────────────────┬───────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    ┌────▼────┐ ┌───▼────┐ ┌───▼─────┐
    │ Lambda  │ │ HTTP   │ │CloudWatch│
    │Functions│ │Endpoint│ │  Logs   │
    └─────────┘ └────────┘ └─────────┘
```

## Cost Estimate

**Minimal Configuration (without custom domain):**
- AppSync Event API: $0.08/million messages
- CloudWatch Logs: ~$0.50/GB ingested
- Data Transfer: $0.09/GB (after 1GB free tier)

**Estimated Monthly Cost for Low-Traffic Application:**
- 1M messages/month: ~$1
- 1GB logs/month: ~$1
- **Total: ~$2/month**

**Note:** Custom domain adds CloudFront distribution costs (~$0.60/month + data transfer).

## Security Best Practices

1. **API Keys**: Rotate regularly, use environment-specific keys
2. **IAM**: Follow principle of least privilege
3. **Cognito**: Use MFA where possible
4. **OIDC**: Validate token issuers
5. **Lambda Authorizers**: Implement caching for performance
6. **CloudWatch Logs**: Review logs regularly for suspicious activity
7. **Custom Domain**: Use TLS 1.2+ only
8. **Handler Code**: Validate and sanitize all inputs

## Troubleshooting

### Connection Issues
```bash
# Check API ID and region
terraform output event_api_id

# Verify API Key validity
terraform output api_key_expires

# Check CloudWatch Logs for errors
aws logs tail /aws/appsync/apis/$(terraform output -raw event_api_id) --follow
```

### Authentication Errors
- **API Key**: Ensure key is not expired
- **IAM**: Verify SigV4 signing is correct
- **Cognito**: Check User Pool ID and region
- **OIDC**: Verify issuer and client ID
- **Lambda**: Check authorizer function logs

### Handler Errors
```bash
# View handler execution logs
aws logs tail /aws/appsync/apis/$(terraform output -raw event_api_id) \
  --filter-pattern "ERROR" --follow
```

## Cleanup

```bash
terraform destroy
```

**Note:** Ensure all active WebSocket connections are closed before destroying.

## Next Steps

1. **Explore Handlers**: Review `handlers/` for JavaScript examples
2. **Test Authentication**: Try different auth types (IAM, Cognito, etc.)
3. **Monitor Logs**: Watch CloudWatch Logs for real-time events
4. **Scale Testing**: Use load testing tools to test capacity
5. **Custom Domain**: Configure Route53 alias for custom domain

## Additional Resources

- [AWS AppSync Event API Documentation](https://docs.aws.amazon.com/appsync/latest/eventapi/)
- [Module README](../../README.md)
- [WebSocket API Protocol](https://docs.aws.amazon.com/appsync/latest/eventapi/websocket-api.html)
- [JavaScript Handler Reference](handlers/README.md)

## License

Apache 2 Licensed. See LICENSE for full details.
