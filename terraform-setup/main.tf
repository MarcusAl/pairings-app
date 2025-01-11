terraform {
  cloud {
    organization = "marcusal-dev"
    workspaces {
      name = "pairings-app"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "backend" {
  ami           = data.aws_ami.linux.id
  instance_type = var.ami_type
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "${var.environment}-backend"
  }

  vpc_security_group_ids = [aws_security_group.backend.id]
}

resource "aws_instance" "frontend" {
  ami           = data.aws_ami.linux.id
  instance_type = var.ami_type
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "${var.environment}-frontend"
  }

  vpc_security_group_ids = [aws_security_group.frontend.id]
}
