# Changelog

All notable changes to this project will be documented in this file.

### [1.6.1](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.6.0...v1.6.1) (2023-01-24)


### Bug Fixes

* Use a version for  to avoid GitHub API rate limiting on CI workflows ([#44](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/44)) ([4e86883](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/4e86883e576edfb89765ba4c090ef1e6e550c780))

## [1.6.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.5.3...v1.6.0) (2022-11-10)


### Features

* Add support to configure batch resolvers ([#41](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/41)) ([6274e94](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/6274e948d8a0054a063dfa7b0c5c69dec02fef26))

### [1.5.3](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.5.2...v1.5.3) (2022-10-27)


### Bug Fixes

* Update CI configuration files to use latest version ([#39](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/39)) ([33f0955](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/33f0955391f2e88744ce4a3612233875b583e162))

### [1.5.2](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.5.1...v1.5.2) (2022-07-09)


### Bug Fixes

* Take app_id_client_regex from user_pool_config ([#35](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/35)) ([#38](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/38)) ([0e37ae7](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/0e37ae758ca22f38e9a3d021451e29e92cb96eb7))

### [1.5.1](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.5.0...v1.5.1) (2022-04-21)


### Bug Fixes

* Fixed datasource not found in functions ([#34](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/34)) ([b4d121a](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/b4d121afca2fe0347160a48d729c2b84698dc31b))

## [1.5.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.4.0...v1.5.0) (2022-04-06)


### Features

* Set api_key_key output to be sensitive ([#33](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/33)) ([b834488](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/b834488c07e882d84766f0a06b052dcdf02f3372))

## [1.4.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.3.0...v1.4.0) (2022-02-14)


### Features

* API & Domain Association ([#27](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/27)) ([4879911](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/487991160784d310de1ea4df9eaf9b32a07f0599))

## [1.3.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.2.0...v1.3.0) (2022-02-14)


### Features

* API Caching ([#29](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/29)) ([4ab6567](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/4ab656775e6c9c2d8130a51e811cc1a332b639eb))

# [1.2.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.1.2...v1.2.0) (2022-01-08)


### Features

* Added support for lambda_authorization_config ([#24](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/24)) ([626d03f](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/626d03fb5c25447cacc6a143384935c5d7409369))

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
