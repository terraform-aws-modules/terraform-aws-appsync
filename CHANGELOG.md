# Changelog

All notable changes to this project will be documented in this file.

## [4.0.1](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v4.0.0...v4.0.1) (2025-10-21)

### Bug Fixes

* Update CI workflow versions to latest ([#74](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/74)) ([31729a6](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/31729a67faad4d79f4486accada04348efaee13c))

## [4.0.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v3.1.0...v4.0.0) (2025-08-25)


### ⚠ BREAKING CHANGES

* Upgrade AWS provider and min required Terraform version to 6.0 and 1.5.7 respectively (#73)

### Features

* Upgrade AWS provider and min required Terraform version to 6.0 and 1.5.7 respectively ([#73](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/73)) ([86028cd](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/86028cd7b58dd8f31cf533c245108fe07d39b977))

## [3.1.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v3.0.0...v3.1.0) (2025-02-02)


### Features

* Add support for configurable logs role description ([#71](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/71)) ([f05674b](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/f05674b00e37bb98641598f8ca2eb635acc2920a))

## [3.0.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.6.0...v3.0.0) (2025-01-09)


### ⚠ BREAKING CHANGES

* Rename resource aws_appsync_api_cache (#70)

### Miscellaneous Chores

* Rename resource aws_appsync_api_cache ([#70](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/70)) ([4b7f0b1](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/4b7f0b1e5d940d4059e29ca7fc408978bfe85842))

## [2.6.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.5.1...v2.6.0) (2025-01-07)


### Features

* Add enhanced_metrics_config ([#68](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/68)) ([c18861e](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/c18861e27772195ffa019204c2dd7c6d96ba64f4))

## [2.5.1](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.5.0...v2.5.1) (2024-10-11)


### Bug Fixes

* Update CI workflow versions to latest ([#66](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/66)) ([bbb3460](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/bbb34605dab79289bed1709e33cdbbb950dc0c63))

## [2.5.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.4.1...v2.5.0) (2024-03-20)


### Features

* Add appsync arguments to support appsync security features ([#61](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/61)) ([355de62](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/355de62bbe08bfc38e6e504d103082ca14a85a77))

## [2.4.1](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.4.0...v2.4.1) (2024-03-07)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#60](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/60)) ([6cacac5](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/6cacac51aad319b9a5f1aac9f60175e533a42df4))

## [2.4.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.3.0...v2.4.0) (2023-11-01)


### Features

* Add support for relational database datasources ([#58](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/58)) ([87ff09b](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/87ff09be76d97ada08fa3483055a4b96d37ea8a3))

## [2.3.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.2.1...v2.3.0) (2023-10-24)


### Features

* Add support for opensearch and eventbridge datasources ([#57](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/57)) ([bd9f700](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/bd9f700313ae6cdbf0b3f16f60465c1f2a423796))

### [2.2.1](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.2.0...v2.2.1) (2023-08-30)


### Bug Fixes

* Fixed APPSYNC_JS resolvers for both kinds (UNIT and PIPELINE) ([#55](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/55)) ([9d3e9b0](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/9d3e9b0beb0d91b518c47771e51bd49768755db0))

## [2.2.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.1.0...v2.2.0) (2023-08-10)


### Features

* Added wrappers for for_each/terragrunt ([#53](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/53)) ([99c1108](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/99c11083bd0aafb6e62baa4422ec39acf2900d2e))

## [2.1.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v2.0.0...v2.1.0) (2023-08-10)


### Features

* Add lambda as additional auth provider ([#52](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/52)) ([9d641a4](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/9d641a415af9834fb3bf305fb4e6c635fdd60ddf))

## [2.0.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.8.0...v2.0.0) (2023-06-05)


### ⚠ BREAKING CHANGES

* Added appsync visibility option, bump AWS provider version to 5.x (#50)

### Features

* Added appsync visibility option, bump AWS provider version to 5.x ([#50](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/50)) ([6fd4bb4](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/6fd4bb473f88ee6718543640b50e1352811189af))

## [1.8.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.7.0...v1.8.0) (2023-04-04)


### Features

* Adds support for JavaScript AppSync Functions ([#49](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/49)) ([265095a](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/265095a3618e48539356c803daccd1eb8d62c06c))

## [1.7.0](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.6.2...v1.7.0) (2023-03-11)


### Features

* Added support for js pipeline resolver ([#46](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/46)) ([d660ffb](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/d660ffb50881fb13067742c26fc4b63b76da425b))

### [1.6.2](https://github.com/terraform-aws-modules/terraform-aws-appsync/compare/v1.6.1...v1.6.2) (2023-03-03)


### Bug Fixes

* Replace hardcoded "aws" parition with data lookup ([#47](https://github.com/terraform-aws-modules/terraform-aws-appsync/issues/47)) ([d6c8501](https://github.com/terraform-aws-modules/terraform-aws-appsync/commit/d6c8501b8abd31576c3db4932fdbf99932ce3347))

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
