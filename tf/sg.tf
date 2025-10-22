locals {
  common_ingress = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    },
    {
      description = "ICMP"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
    },
    {
      description = "TCP port 5000"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
    }
  ]
}

resource "aws_security_group" "web_server_1" {
  name        = "allow_ssh_icmp_tcp_5000"
  description = "Allow SSH, ICMP, and TCP port 5000"

  dynamic "ingress" {
    for_each = local.common_ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_server_1_internal" {
  name        = "vpc-only-allow_ssh_icmp_tcp_5000"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = local.common_ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [data.aws_vpc.default.cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}