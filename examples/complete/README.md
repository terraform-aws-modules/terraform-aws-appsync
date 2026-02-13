# Complete AWS AppSync example

Configuration in this directory creates AWS AppSync with various types of datasources and resolvers.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.28 |
| <a name="requirement_random"></a> [random](#requirement_random)          | >= 2.0  |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | >= 6.28 |
| <a name="provider_random"></a> [random](#provider_random) | >= 2.0  |

## Modules

| Name                                                        | Source                        | Version |
| ----------------------------------------------------------- | ----------------------------- | ------- |
| <a name="module_acm"></a> [acm](#module_acm)                | terraform-aws-modules/acm/aws | ~> 6.0  |
| <a name="module_appsync"></a> [appsync](#module_appsync)    | ../../                        | n/a     |
| <a name="module_disabled"></a> [disabled](#module_disabled) | ../../                        | n/a     |

## Resources

| Name                                                                                                                                       | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool)                | resource    |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client)  | resource    |
| [aws_route53_record.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                       | resource    |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)                          | resource    |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet)                                      | resource    |
| [aws_acm_certificate.existing_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)              | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)                       | data source |

## Inputs

| Name                                                                                                                                          | Description                                | Type     | Default                              | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | -------- | ------------------------------------ | :------: |
| <a name="input_existing_acm_certificate_domain_name"></a> [existing_acm_certificate_domain_name](#input_existing_acm_certificate_domain_name) | Existing ACM certificate domain name       | `string` | `"terraform-aws-modules.modules.tf"` |    no    |
| <a name="input_region"></a> [region](#input_region)                                                                                           | AWS region where resources will be created | `string` | `"eu-west-1"`                        |    no    |
| <a name="input_route53_domain_name"></a> [route53_domain_name](#input_route53_domain_name)                                                    | Existing Route 53 domain name              | `string` | `"terraform-aws-modules.modules.tf"` |    no    |
| <a name="input_use_existing_acm_certificate"></a> [use_existing_acm_certificate](#input_use_existing_acm_certificate)                         | Whether to use an existing ACM certificate | `bool`   | `false`                              |    no    |
| <a name="input_use_existing_route53_zone"></a> [use_existing_route53_zone](#input_use_existing_route53_zone)                                  | Whether to use an existing Route 53 zone   | `bool`   | `true`                               |    no    |

## Outputs

| Name                                                                                                                       | Description                                                 |
| -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| <a name="output_appsync_api_key_id"></a> [appsync_api_key_id](#output_appsync_api_key_id)                                  | Map of API Key ID (Formatted as ApiId:Key)                  |
| <a name="output_appsync_api_key_key"></a> [appsync_api_key_key](#output_appsync_api_key_key)                               | Map of API Keys                                             |
| <a name="output_appsync_datasource_arn"></a> [appsync_datasource_arn](#output_appsync_datasource_arn)                      | Map of ARNs of datasources                                  |
| <a name="output_appsync_domain_hosted_zone_id"></a> [appsync_domain_hosted_zone_id](#output_appsync_domain_hosted_zone_id) | The ID of your Amazon Route 53 hosted zone                  |
| <a name="output_appsync_domain_id"></a> [appsync_domain_id](#output_appsync_domain_id)                                     | The Appsync Domain name                                     |
| <a name="output_appsync_domain_name"></a> [appsync_domain_name](#output_appsync_domain_name)                               | The domain name AppSync provides                            |
| <a name="output_appsync_graphql_api_arn"></a> [appsync_graphql_api_arn](#output_appsync_graphql_api_arn)                   | ARN of GraphQL API                                          |
| <a name="output_appsync_graphql_api_fqdns"></a> [appsync_graphql_api_fqdns](#output_appsync_graphql_api_fqdns)             | Map of FQDNs associated with the API (no protocol and path) |
| <a name="output_appsync_graphql_api_id"></a> [appsync_graphql_api_id](#output_appsync_graphql_api_id)                      | ID of GraphQL API                                           |
| <a name="output_appsync_graphql_api_uris"></a> [appsync_graphql_api_uris](#output_appsync_graphql_api_uris)                | Map of URIs associated with the API                         |
| <a name="output_appsync_resolver_arn"></a> [appsync_resolver_arn](#output_appsync_resolver_arn)                            | Map of ARNs of resolvers                                    |

<!-- END_TF_DOCS -->
