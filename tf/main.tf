provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-052064a798f08f0d3"
  instance_type = "t3.micro"

  tags = {
    Name = "My_Web_Server_1"
  }

  security_groups = [aws_security_group.web_server_1.name]

  key_name = "key-pair-1"

  user_data = <<-EOF
              #!/bin/bash
              # Install requirements
              sudo yum install python -y
              sudo yum install pip -y
              pip install flask
              sudo yum install git -y
              git clone https://github.com/HeatMint/prac-tf.git
              pip install gunicorn
              python ./prac-tf/flask/app.py
              EOF
}
