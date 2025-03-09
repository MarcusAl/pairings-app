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

# Redis subnet group
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = [aws_subnet.private.id]
}

# Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id         = "${var.environment}-redis"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  port               = 6379
  security_group_ids = [aws_security_group.redis.id]
  subnet_group_name  = aws_elasticache_subnet_group.redis.name

  tags = {
    Name        = "${var.environment}-redis"
    Environment = var.environment
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Load balancer
resource "aws_lb" "api" {
  name               = "${var.environment}-api-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public2.id]

  tags = {
    Name        = "${var.environment}-api-lb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "api" {
  name     = "${var.environment}-api-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/up"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private2.id] # RDS requires at least 2 subnets

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Database
resource "aws_db_instance" "postgres" {
  identifier            = "${var.environment}-postgres"
  engine                = "postgres"
  engine_version        = "15.10"
  instance_class        = "db.t3.medium"
  allocated_storage     = 50
  max_allocated_storage = 100

  db_name             = "pairings_api_production"
  username            = var.db_username
  password            = var.db_password
  publicly_accessible = false
  port                = 5432

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.environment}-postgres-final-snapshot-${formatdate("YYYY-MM-DD-HH-mm", timestamp())}" # Snapshot name must be unique

  apply_immediately = true

  parameter_group_name = "default.postgres15"

  tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
  }
}

# API
resource "aws_instance" "backend" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.ami_type
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.deployer.key_name

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    aws_region     = var.aws_region
    aws_account_id = var.aws_account_id
    environment    = var.environment
    db_username    = var.db_username
    db_password    = var.db_password
    ecr_image_url  = var.ecr_image_url
    redis_endpoint = aws_elasticache_cluster.redis.cache_nodes[0].address
    db_endpoint    = aws_db_instance.postgres.endpoint
    db_name        = aws_db_instance.postgres.db_name
  })

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.environment}-api"
  }

  vpc_security_group_ids = [aws_security_group.backend.id]
}

resource "aws_lb_target_group_attachment" "api" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.backend.id
  port             = 3000
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-deployer-key"
  public_key = var.ssh_public_key
}

# SSM Parameter for Rails Master Key
resource "aws_ssm_parameter" "rails_master_key" {
  name        = "/${var.environment}/rails/master_key"
  description = "Rails Master Key for ${var.environment}"
  type        = "SecureString"
  value       = var.rails_master_key

  tags = {
    Environment = var.environment
  }
}
