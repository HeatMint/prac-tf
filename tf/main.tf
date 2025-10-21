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
