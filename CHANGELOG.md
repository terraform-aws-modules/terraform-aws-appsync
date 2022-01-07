# Changelog

All notable changes to this project will be documented in this file.

## [1.1.2](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.1.1...v1.1.2) (2022-01-07)


### Bug Fixes

* Fixed mixed resolvers ([#25](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/25)) ([d6bc2ce](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/d6bc2cebec4e0f495462a534fbf2c0d19363a266))

## [1.1.1](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.1.0...v1.1.1) (2021-11-22)


### Bug Fixes

* update CI/CD process to enable auto-release workflow ([#22](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/22)) ([6cedbdf](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/6cedbdf0c1fe8051a90b7cbb4a0963c75dc26aba))

<a name="v1.1.0"></a>
## [v1.1.0] - 2021-09-08

- feat: Add iam_permission_boundary to IAM role ([#18](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/18))
- chore: update CI/CD to use stable `terraform-docs` release artifact and discoverable Apache2.0 license ([#15](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/15))
- chore: Updated versions&comments in examples


<a name="v1.0.0"></a>
## [v1.0.0] - 2021-04-26

- feat: Shorten outputs (removing this_) ([#14](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/14))


<a name="v0.9.0"></a>
## [v0.9.0] - 2021-04-22

- feat: add support for functions ([#13](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/13))
- chore: update documentation and pin `terraform_docs` version to avoid future changes ([#12](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/12))
- chore: align ci-cd static checks to use individual minimum Terraform versions ([#11](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/11))
- chore: add ci-cd workflow for pre-commit checks ([#10](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/10))


<a name="v0.8.0"></a>
## [v0.8.0] - 2020-12-06

- fix: dynamodb service role ([#7](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/7))


<a name="v0.7.0"></a>
## [v0.7.0] - 2020-11-16

- fix: Fixed terraform versions ([#6](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/6))


<a name="v0.6.0"></a>
## [v0.6.0] - 2020-11-16

- fix: terraform output after the resources are destroyed without any error ([#5](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/5))
- Added disabled example
- Update outputs.tf


<a name="v0.5.0"></a>
## [v0.5.0] - 2020-10-26

- fix: Fixed ARN for DynamoDB table in IAM role created by AppSync


<a name="v0.4.0"></a>
## [v0.4.0] - 2020-10-04

- feat: Added support for all authorization providers ([#2](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/2))


<a name="v0.3.0"></a>
## [v0.3.0] - 2020-09-15

- Added GraphQL FQDN to outputs
- docs: Document migration path for Terraform resources (datasource vs resolver)


<a name="v0.2.0"></a>
## [v0.2.0] - 2020-08-25

- fix: Updated VTL templates to reflect direct Lambda resolvers integration ([#1](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/1))


<a name="v0.1.0"></a>
## v0.1.0 - 2020-08-24

- Add all the code for AppSync module


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.1.0...HEAD
[v1.1.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.0.0...v1.1.0
[v1.0.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.9.0...v1.0.0
[v0.9.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.8.0...v0.9.0
[v0.8.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.7.0...v0.8.0
[v0.7.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.5.0...v0.6.0
[v0.5.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v0.1.0...v0.2.0
