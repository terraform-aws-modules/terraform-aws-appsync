# Complete AWS AppSync example

Configuration in this directory creates AWS AppSync with various types of datasources and resolvers.


## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| random | n/a |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| this\_appsync\_api\_key\_id | Map of API Key ID (Formatted as ApiId:Key) |
| this\_appsync\_api\_key\_key | Map of API Keys |
| this\_appsync\_datasource\_arn | Map of ARNs of datasources |
| this\_appsync\_graphql\_api\_arn | ARN of GraphQL API |
| this\_appsync\_graphql\_api\_id | ID of GraphQL API |
| this\_appsync\_graphql\_api\_uris | Map of URIs associated with the API |
| this\_appsync\_resolver\_arn | Map of ARNs of resolvers |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
