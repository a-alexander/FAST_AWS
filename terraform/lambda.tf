terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.21.0"
    }
  }
}

variable "lambda_function_name" {
  default = "fast_aws"
}

variable "api_resource_path" {
  default = "{proxy+}"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "stage_name" {
  default = "dev"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_lambda_function" "test_lambda" {
  s3_bucket     = "asa-lambdas"
  s3_key        = "${var.lambda_function_name}.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.handler"
  runtime       = "python3.8"
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.example,
    aws_iam_role.iam_for_lambda,
  ]
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.example.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.test_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.test_lambda.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}


//
//# API Gateway
//resource "aws_api_gateway_rest_api" "lambda_api" {
//  name = var.lambda_function_name
//}
//
//resource "aws_api_gateway_resource" "resource" {
//  path_part = var.api_resource_path
//  parent_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
//  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
//}
//
//resource "aws_api_gateway_method" "method" {
//  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
//  resource_id   = aws_api_gateway_resource.resource.id
//  http_method   = "ANY"
//  authorization = "NONE"
//}
//
//resource "aws_api_gateway_integration" "integration" {
//  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
//  resource_id             = aws_api_gateway_resource.resource.id
//  http_method             = aws_api_gateway_method.method.http_method
//  integration_http_method = "ANY"
//  type                    = "AWS_PROXY"
//  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.test_lambda.arn}/invocations"
//}
//
//resource "aws_api_gateway_deployment" "deployment" {
//  depends_on = [aws_api_gateway_integration.integration]
//  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
//  stage_name  = var.stage_name
//}


# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
  "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}