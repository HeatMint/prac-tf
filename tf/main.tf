provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0199d4b5b8b4fde0e"
  instance_type = "t3.micro"

  tags = {
    Name = "My_Web_Server_1"
  }

  security_groups = [aws_security_group.web_server_1.name]

  key_name = "key-pair-2"

  user_data = file("${path.module}/../scripts/launch_ec2.sh")
}

# 1. Find the default VPC in the selected region.
data "aws_vpc" "default" {
  default = true
}

# 2. Find all subnets associated with the default VPC.
#    Lambda requires at least one, but it's best to provide all of them for high availability.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. Find the default security group for the default VPC.
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}


# Assume Role Policy for Lambda Service
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Create the IAM Role for the Lambda function
resource "aws_iam_role" "lambda_vpc_role" {
  name               = "lambda_vpc_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Attach the basic execution policy (for CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach the VPC access policy (for creating network interfaces)
# THIS IS CRITICAL for VPC-enabled Lambdas.
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# Package the Lambda function code
data "archive_file" "lambda_func" {
  type        = "zip"
  source_file = "${path.module}/../scripts/lambda_1/lambda_function.py"
  output_path = "${path.module}/../scripts/lambda_1/function.zip"
}

# Lambda function
resource "aws_lambda_function" "auto" {
  filename         = data.archive_file.lambda_func.output_path
  function_name    = "auto_lambda"
  role             = aws_iam_role.lambda_vpc_role.arn
  handler          = "auto_lambda.handler"
  source_code_hash = data.archive_file.lambda_func.output_base64sha256

  # This block connects the Lambda to the Default VPC.
  vpc_config {
    # Use the IDs of the subnets and security group found by our data sources.
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [data.aws_security_group.default.id]
  }

  # Add a dependency to ensure the role and policies are created first.
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_vpc_access,
  ]

  runtime = "python3.9"

  environment {
    variables = {
      PRIVATE_IP = aws_instance.web_server.private_ip
    }
  }

  tags = {
    Environment = "production"
    Application = "example"
  }
}

# 6. Create the public Function URL.
resource "aws_lambda_function_url" "public_url" {
  function_name      = aws_lambda_function.auto.function_name
  authorization_type = "NONE" # This makes the URL publicly accessible
}

# 7. Output the generated URL so you can easily access it.
output "lambda_function_url" {
  description = "The publicly accessible URL for the Lambda function."
  value       = aws_lambda_function_url.public_url.function_url
}