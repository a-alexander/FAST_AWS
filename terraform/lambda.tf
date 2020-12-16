terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.21.0"
    }
  }
}


resource "aws_lambda_function" "test_lambda" {
//  s3_bucket     = "asa-lambdas"
//  s3_key        = "${var.lambda_function_name}/v${var.app_version}.zip"
  filename          = "lambda_build.zip"
  source_code_hash  = base64sha256(filesha256("lambda_build.zip"))
  function_name     = var.lambda_function_name
  role              = aws_iam_role.iam_for_lambda.arn
  handler           = "main.handler"
  runtime           = "python3.8"
  depends_on        = [
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


# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}
