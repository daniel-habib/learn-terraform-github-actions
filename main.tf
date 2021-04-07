terraform {
  required_providers {
    aws = {
      version = "3.26.0"
    }
    random = {
      version = "3.0.1"
    }
  }
  required_version = "~> 0.12"

  backend "s3" {
    encrypt = true
    bucket  = "papaya-deploy"
    region  = "us-west-1"
    key     = "terraform/state/gh-actions-demo.tfstate"
  }
}


provider "aws" {
  region = "eu-west-2"
}

variable "environment" {
  type = string
}

resource "random_pet" "sg" {}

resource "aws_instance" "web" {
  ami                    = "ami-0fbec3e0504ee1970"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, ${var.environment} World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
