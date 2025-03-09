variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "pairings-dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "ami_type" {
  type        = string
  description = "AMI type"
  default     = "t3.medium"
}

variable "ecr_image_url" {
  description = "URL of the Docker image in ECR"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for EC2 access"
  type        = string
}

variable "rails_master_key" {
  description = "Rails master key for decrypting credentials"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
