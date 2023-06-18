terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider (keys and region are been passed as env variable in the env.list file)
provider "aws" {}

# S3 bucket
resource "aws_s3_bucket" "tf-bucket" {
  bucket = "raw-bankruptcy-prediction-dataset"

  tags = {
    Name = "kaggle_api_call"
    Environment = "Dev"
  }
}

# Lambda function needs
# 1. aws_iam_role
# 2. aws_iam_policy
# 3. aws_iam_role_policy_attachment
# 4. data "archive_file" (will zip the python code for you)
# 5. aws_lambda_function

# aws_iam_role
resource "aws_iam_role" "lambda_role" {
    name = "tf_aws_lambda_role"
assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal" : {
                "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
}
EOF
}

# aws_iam_policy
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "tf_aws_lambda_policy"
  path        = "/"

policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [        
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  }
EOF
}

# aws_iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "attach_lambda_policy_to_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# data "archive_file"
data "archive_file" "zip_the_python_code" {
  type = "zip"
  source_dir = "${path.module}/testes/"
  output_path = "${path.module}/testes/hello_world.zip"
}

# aws_lambda_function
resource "aws_lambda_function" "terraform_lambda_func" {
  filename = "${path.module}/testes/hello_world.zip"
  function_name = "hello_world_lambda"
  role = aws_iam_role.lambda_role.arn
  handler = "hello_world.lambda_handler"
  runtime = "python3.8"
  depends_on = [aws_iam_role_policy_attachment.attach_lambda_policy_to_role]
}

output "terraform_aws_role_output" {
  value = aws_iam_role.lambda_role.name
}

output "terraform_aws_role_arn_output" {
  value = aws_iam_role.lambda_role.arn
}

output "terraform_logging_arn_output" {
  value = aws_iam_policy.iam_policy_for_lambda.arn
}