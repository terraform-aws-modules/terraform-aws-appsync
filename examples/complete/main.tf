provider "aws" {
  region = var.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}

locals {
  # Removing trailing dot from domain - just to be sure :)
  route53_domain_name = trimsuffix(var.route53_domain_name, ".")
}

data "aws_route53_zone" "this" {
  count = var.use_existing_route53_zone ? 1 : 0

  name         = local.route53_domain_name
  private_zone = false
}

resource "aws_route53_zone" "this" {
  count = !var.use_existing_route53_zone ? 1 : 0

  name = local.route53_domain_name
}

resource "aws_route53_record" "api" {
  zone_id = try(data.aws_route53_zone.this[0].zone_id, aws_route53_zone.this[0].zone_id)
  name    = "api.${var.route53_domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [module.appsync.appsync_domain_name]
}

data "aws_acm_certificate" "existing_certificate" {
  count = var.use_existing_acm_certificate ? 1 : 0

  region = "us-east-1"

  domain = var.existing_acm_certificate_domain_name
}

module "acm" {
  count = var.use_existing_acm_certificate ? 0 : 1

  region = "us-east-1"

  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.0"

  domain_name = local.route53_domain_name
  zone_id     = try(data.aws_route53_zone.this[0].zone_id, aws_route53_zone.this[0].zone_id)

  subject_alternative_names = [
    "*.alerts.${local.route53_domain_name}",
    "new.sub.${local.route53_domain_name}",
    "*.${local.route53_domain_name}",
    "alerts.${local.route53_domain_name}",
  ]

  wait_for_validation = true

  validation_method = "DNS"

  tags = {
    Name = local.route53_domain_name
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "appsync" {
  source = "../../"

  name = random_pet.this.id

  schema = file("schema.graphql")

  visibility = "GLOBAL"

  domain_name_association_enabled = true
  caching_enabled                 = true

  introspection_config = "DISABLED"
  query_depth_limit    = 10
  resolver_count_limit = 25

  domain_name             = "api.${var.route53_domain_name}"
  domain_name_description = "My ${random_pet.this.id} AppSync Domain"
  certificate_arn         = var.use_existing_acm_certificate ? data.aws_acm_certificate.existing_certificate[0].arn : module.acm[0].acm_certificate_arn

  caching_behavior                 = "PER_RESOLVER_CACHING"
  cache_type                       = "SMALL"
  cache_ttl                        = 60
  cache_at_rest_encryption_enabled = true
  cache_transit_encryption_enabled = true

  api_keys = {
    future  = "2021-08-20T15:00:00Z"
    default = null
  }

  authentication_type = "OPENID_CONNECT"

  lambda_authorizer_config = {
    authorizer_uri = "arn:aws:lambda:eu-west-1:835367859851:function:appsync_auth_1"
  }

  openid_connect_config = {
    issuer    = "https://www.issuer1.com/"
    client_id = "client_id1"
    auth_ttl  = 100
    iat_ttl   = 200
  }

  additional_authentication_provider = {
    iam = {
      authentication_type = "AWS_IAM"
    }
    openid_connect_2 = {
      authentication_type = "OPENID_CONNECT"

      openid_connect_config = {
        issuer    = "https://www.issuer2.com/"
        client_id = "client_id2"
      }
    }

    my_user_pool = {
      authentication_type = "AMAZON_COGNITO_USER_POOLS"

      user_pool_config = {
        user_pool_id        = aws_cognito_user_pool.this.id
        app_id_client_regex = aws_cognito_user_pool_client.this.id
      }
    }

    lambda = {
      authentication_type = "AWS_LAMBDA"
      lambda_authorizer_config = {
        authorizer_uri = "arn:aws:lambda:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:function:appsync_auth_2"
      }
    }
  }

  functions = {
    None = {
      kind                     = "PIPELINE"
      type                     = "Query"
      data_source              = "None"
      request_mapping_template = <<EOF
      {
          "payload": $util.toJson($context.args)
      }
      EOF

      response_mapping_template = "$util.toJson($context.result)"
    }

    Javascript = {
      data_source    = "lambda1"
      max_batch_size = 10
      runtime = {
        name = "APPSYNC_JS"
      }
      code = file("src/function.js")
    }
  }

  datasources = {
    registry_terraform_io = {
      type     = "HTTP"
      endpoint = "https://registry.terraform.io"
    }

    None = {
      type = "NONE"
    }

    lambda1 = {
      type = "AWS_LAMBDA"

      # Note: dynamic references (module.aws_lambda_function1.lambda_function_arn) do not work unless you create this resource in advance
      function_arn = "arn:aws:lambda:eu-west-1:835367859851:function:index_1"
    }

    lambda2 = {
      type = "AWS_LAMBDA"

      # Note: dynamic references (module.aws_lambda_function2.lambda_function_arn) do not work unless you create this resource in advance
      function_arn = "arn:aws:lambda:eu-west-1:835367859851:function:index_2"
      # service_role_arn = "arn:aws:iam::835367859851:role/lambda1-service"
    }

    dynamodb1 = {
      type = "AMAZON_DYNAMODB"

      # Note: dynamic references (module.dynamodb_table1.dynamodb_table_id) do not work unless you create this resource in advance
      table_name = "my-table"
      region     = "eu-west-1"
    }

    # Elasticsearch support has not been finished & tested
    elasticsearch1 = {
      type = "AMAZON_ELASTICSEARCH"

      # Note: dynamic references (module.elasticsearch1.id) do not work do not work unless you create this resource in advance
      endpoint = "https://search-my-domain.eu-west-1.es.amazonaws.com"
      region   = "eu-west-1"
    }

    # Opensearch Service support has not been finished & tested
    opensearchservice1 = {
      type = "AMAZON_OPENSEARCH_SERVICE"

      # Note: dynamic references (module.opensearchservice1.id) do not work do not work unless you create this resource in advance
      endpoint = "https://search-my-domain-2.eu-west-1.es.amazonaws.com"
      region   = "eu-west-1"
    }

    eventbridge1 = {
      type          = "AMAZON_EVENTBRIDGE"
      event_bus_arn = "arn:aws:events:us-west-1:135367859850:event-bus/eventbridge1"
    }

    rds1 = {
      type          = "RELATIONAL_DATABASE"
      cluster_arn   = "arn:aws:rds:us-west-1:135367859850:cluster:rds1"
      secret_arn    = "arn:aws:secretsmanager:us-west-1:135367859850:secret:rds-secret1"
      database_name = "mydb"
      schema        = "myschema"
    }
  }

  resolvers = {
    "Mutation.putPost" = {
      data_source   = "lambda1"
      direct_lambda = true
    }

    "Post.id" = {
      data_source    = "lambda2"
      direct_lambda  = true
      max_batch_size = 10
    }

    "Post.title" = {
      data_source      = "registry_terraform_io"
      request_template = <<EOF
{
    "version": "2018-05-29",
    "method": "GET",
    "resourcePath": "/",
    "params":{
        "headers": $utils.http.copyheaders($ctx.request.headers)
    }
}
EOF

      response_template = <<EOF
#if($ctx.result.statusCode == 200)
    $ctx.result.body
#else
    $utils.appendError($ctx.result.body, $ctx.result.statusCode)
#end
EOF
    }

    "Query.singlePost" = {
      data_source   = "lambda1"
      direct_lambda = true
      caching_keys = [
        "$context.identity.sub",
        "$context.arguments.id",
      ]
    }

    "Query.none" = {
      response_template = "{}"
      request_template  = "$util.toJson($context.result)"
      kind              = "PIPELINE"
      type              = "Query"
      field             = "none"
      functions = [
        "None",
      ]
    }

    "Query.singleComment" = {
      kind  = "UNIT"
      type  = "Query"
      field = "singleComment"
      code  = file("src/function.js")
      runtime = {
        name            = "APPSYNC_JS"
        runtime_version = "1.0.0"
      }
      data_source = "dynamodb1"
    }

    "Query.user" = {
      kind  = "PIPELINE"
      type  = "Query"
      field = "user"
      runtime = {
        name = "APPSYNC_JS"
      }
      code = file("src/index.js")
      functions = [
        "None",
      ]
    }

    "Query.user" = {
      kind  = "PIPELINE"
      type  = "Query"
      field = "user"
      runtime = {
        name = "APPSYNC_JS"
      }
      code = file("src/function.js")
      functions = [
        "Javascript",
      ]
    }
  }

  enhanced_metrics_config = {
    data_source_level_metrics_behavior = "PER_DATA_SOURCE_METRICS"
    operation_level_metrics_config     = "ENABLED"
    resolver_level_metrics_behavior    = "FULL_REQUEST_RESOLVER_METRICS"
  }
}

##################
# Extra resources
##################

resource "random_pet" "this" {
  length = 2
}

resource "aws_cognito_user_pool" "this" {
  name = "user-pool-${random_pet.this.id}"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "user-pool-client-${random_pet.this.id}"
  user_pool_id = aws_cognito_user_pool.this.id
}

#module "aws_lambda_function1" {
#  source = "terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_lambda_function"
#}
#
#module "aws_lambda_function2" {
#  source = "terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_lambda_function"
#}
#
#module "dynamodb_table1" {
#  source = "terraform-aws-modules/dynamodb-table/aws"
#
#  name     = random_pet.this.id
#  hash_key = "id"
#
#  attributes = [
#    {
#      name = "id"
#      type = "N"
#    }
#  ]
#}

###########
# Disabled
###########
module "disabled" {
  source = "../../"

  create_graphql_api = false
}
