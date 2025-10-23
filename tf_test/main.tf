provider "aws" {
  region = "us-east-2"
}

resource "aws_launch_template" "web_server" {
  image_id           = "ami-0199d4b5b8b4fde0e"
  instance_type = "t3.micro"

  tags = {
    Name = "My_Web_Server_1"
  }

  vpc_security_group_ids = [aws_security_group.web_server_1_internal.id]

  key_name = "key-pair-2"

  user_data = filebase64("${path.module}/../scripts/launch_ec2.sh")
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
