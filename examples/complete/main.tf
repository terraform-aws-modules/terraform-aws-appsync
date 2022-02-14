provider "aws" {
  region = "eu-west-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}

locals {
  # Use existing (via data source) or create new zone (will fail validation, if zone is not reachable)
  use_existing_route53_zone = true

  domain = "terraform-aws-modules.modules.tf"

  # Removing trailing dot from domain - just to be sure :)
  domain_name = trimsuffix(local.domain, ".")
}

data "aws_route53_zone" "this" {
  count = local.use_existing_route53_zone ? 1 : 0

  name         = local.domain_name
  private_zone = false
}

resource "aws_route53_zone" "this" {
  count = !local.use_existing_route53_zone ? 1 : 0
  name  = local.domain_name
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = "api.${local.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [module.appsync.appsync_domain_name]
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3"

  domain_name = local.domain_name
  zone_id     = coalescelist(data.aws_route53_zone.this.*.zone_id, aws_route53_zone.this.*.zone_id)[0]

  subject_alternative_names = [
    "*.alerts.${local.domain_name}",
    "new.sub.${local.domain_name}",
    "*.${local.domain_name}",
    "alerts.${local.domain_name}",
  ]

  wait_for_validation = true

  tags = {
    Name = local.domain_name
  }

  providers = {
    aws = aws.us-east-1
  }
}

module "appsync" {
  source = "../../"

  name = random_pet.this.id

  schema = file("schema.graphql")

  domain_name_association_enabled = true

  domain_name             = "api.${local.domain}"
  domain_name_description = "My ${random_pet.this.id} AppSync Domain"
  certificate_arn         = module.acm.acm_certificate_arn

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
        user_pool_id = aws_cognito_user_pool.this.id
      }
    }
  }

  functions = {
    None = {
      kind                      = "PIPELINE"
      type                      = "Query"
      data_source               = "None"
      request_mapping_template  = <<EOF
{
    "payload": $util.toJson($context.args)
}
EOF
      response_mapping_template = "$util.toJson($context.result)"
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
  }

  resolvers = {
    "Mutation.putPost" = {
      data_source   = "lambda1"
      direct_lambda = true
    }

    "Post.id" = {
      data_source   = "lambda2"
      direct_lambda = true
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
