
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

variable "app_version" {
}
