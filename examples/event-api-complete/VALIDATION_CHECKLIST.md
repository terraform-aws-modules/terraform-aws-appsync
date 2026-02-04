# Event API Complete Example - Validation Checklist

This checklist validates that the example demonstrates all Event API features.

## Required Files
- [ ] main.tf - Complete Event API configuration
- [ ] variables.tf - Input variables with defaults
- [ ] outputs.tf - Output values for testing
- [ ] versions.tf - Terraform and provider versions
- [ ] README.md - Usage documentation
- [ ] handlers/ - JavaScript handler examples

## Feature Coverage

### Authentication Types
- [ ] API_KEY authentication configured
- [ ] IAM authentication configured
- [ ] AWS_COGNITO_USER_POOLS authentication configured
- [ ] OPENID_CONNECT authentication configured
- [ ] AWS_LAMBDA authentication configured

### Channel Namespaces
- [ ] Multiple channel namespaces defined
- [ ] JavaScript code handlers included
- [ ] Lambda function handlers configured

### Datasources
- [ ] Lambda datasource configured
- [ ] HTTP datasource configured
- [ ] IAM roles auto-generated for datasources

### Domain Name Association
- [ ] Custom domain name configured
- [ ] ACM certificate reference included
- [ ] Domain association enabled

### CloudWatch Logs
- [ ] Logging enabled
- [ ] Log level configured
- [ ] IAM role for logs configured

### Terraform Quality
- [ ] terraform validate passes
- [ ] terraform fmt applied
- [ ] No hard-coded values (use variables)
- [ ] Outputs defined for verification

## Documentation Quality
- [ ] README explains what the example demonstrates
- [ ] README includes prerequisites (ACM cert, etc.)
- [ ] README shows how to deploy
- [ ] README shows how to test
- [ ] Inline comments explain complex configurations

Run `terraform validate` to verify configuration:
```bash
cd examples/event-api-complete
terraform init
terraform validate
```
