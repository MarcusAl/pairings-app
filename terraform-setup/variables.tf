variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "ami_type" {
  type        = string
  description = "AMI type"
  default     = "t2.micro"
}

variable "dev_ip" {
  description = "Developer IP addr for SSH access"
  type        = string
}
