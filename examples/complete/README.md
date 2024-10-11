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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 3 |
| <a name="module_appsync"></a> [appsync](#module\_appsync) | ../../ | n/a |
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_route53_record.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appsync_api_key_id"></a> [appsync\_api\_key\_id](#output\_appsync\_api\_key\_id) | Map of API Key ID (Formatted as ApiId:Key) |
| <a name="output_appsync_api_key_key"></a> [appsync\_api\_key\_key](#output\_appsync\_api\_key\_key) | Map of API Keys |
| <a name="output_appsync_datasource_arn"></a> [appsync\_datasource\_arn](#output\_appsync\_datasource\_arn) | Map of ARNs of datasources |
| <a name="output_appsync_domain_hosted_zone_id"></a> [appsync\_domain\_hosted\_zone\_id](#output\_appsync\_domain\_hosted\_zone\_id) | The ID of your Amazon Route 53 hosted zone |
| <a name="output_appsync_domain_id"></a> [appsync\_domain\_id](#output\_appsync\_domain\_id) | The Appsync Domain name |
| <a name="output_appsync_domain_name"></a> [appsync\_domain\_name](#output\_appsync\_domain\_name) | The domain name AppSync provides |
| <a name="output_appsync_graphql_api_arn"></a> [appsync\_graphql\_api\_arn](#output\_appsync\_graphql\_api\_arn) | ARN of GraphQL API |
| <a name="output_appsync_graphql_api_fqdns"></a> [appsync\_graphql\_api\_fqdns](#output\_appsync\_graphql\_api\_fqdns) | Map of FQDNs associated with the API (no protocol and path) |
| <a name="output_appsync_graphql_api_id"></a> [appsync\_graphql\_api\_id](#output\_appsync\_graphql\_api\_id) | ID of GraphQL API |
| <a name="output_appsync_graphql_api_uris"></a> [appsync\_graphql\_api\_uris](#output\_appsync\_graphql\_api\_uris) | Map of URIs associated with the API |
| <a name="output_appsync_resolver_arn"></a> [appsync\_resolver\_arn](#output\_appsync\_resolver\_arn) | Map of ARNs of resolvers |
<!-- END_TF_DOCS -->
