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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.46 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.46 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_appsync"></a> [appsync](#module\_appsync) | ../../ |  |
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../ |  |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_appsync_api_key_id"></a> [this\_appsync\_api\_key\_id](#output\_this\_appsync\_api\_key\_id) | Map of API Key ID (Formatted as ApiId:Key) |
| <a name="output_this_appsync_api_key_key"></a> [this\_appsync\_api\_key\_key](#output\_this\_appsync\_api\_key\_key) | Map of API Keys |
| <a name="output_this_appsync_datasource_arn"></a> [this\_appsync\_datasource\_arn](#output\_this\_appsync\_datasource\_arn) | Map of ARNs of datasources |
| <a name="output_this_appsync_graphql_api_arn"></a> [this\_appsync\_graphql\_api\_arn](#output\_this\_appsync\_graphql\_api\_arn) | ARN of GraphQL API |
| <a name="output_this_appsync_graphql_api_fqdns"></a> [this\_appsync\_graphql\_api\_fqdns](#output\_this\_appsync\_graphql\_api\_fqdns) | Map of FQDNs associated with the API (no protocol and path) |
| <a name="output_this_appsync_graphql_api_id"></a> [this\_appsync\_graphql\_api\_id](#output\_this\_appsync\_graphql\_api\_id) | ID of GraphQL API |
| <a name="output_this_appsync_graphql_api_uris"></a> [this\_appsync\_graphql\_api\_uris](#output\_this\_appsync\_graphql\_api\_uris) | Map of URIs associated with the API |
| <a name="output_this_appsync_resolver_arn"></a> [this\_appsync\_resolver\_arn](#output\_this\_appsync\_resolver\_arn) | Map of ARNs of resolvers |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
