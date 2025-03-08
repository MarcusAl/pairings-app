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

  db_name  = "pairings_api_production"
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.environment}-postgres-final-snapshot-${formatdate("YYYY-MM-DD-HH-mm", timestamp())}" # Snapshot name must be unique

  apply_immediately = true

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

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
              echo "Starting user data script..."
              
              # Install dependencies
              echo "Installing AWS CLI and Docker..."
              sudo yum update -y
              sudo yum install -y aws-cli docker
              
              echo "Starting Docker service..."
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -a -G docker ec2-user
              
              # Login to ECR - Fixed command
              echo "Logging into ECR..."
              aws ecr get-login-password \
                --region ${var.aws_region} | \
                sudo docker login \
                --username AWS \
                --password-stdin \
                ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
              
              echo "Fetching Rails master key..."
              RAILS_MASTER_KEY=$(aws ssm get-parameter \
                --region ${var.aws_region} \
                --name "/${var.environment}/rails/master_key" \
                --with-decryption \
                --query Parameter.Value \
                --output text || echo "Failed to fetch master key")
              
              if [ -z "$RAILS_MASTER_KEY" ]; then
                echo "Error: Failed to fetch RAILS_MASTER_KEY"
                exit 1
              fi
              
              echo "Pulling Docker image..."
              sudo docker pull ${var.ecr_image_url}
              
              echo "Running Docker container..."
              sudo docker run -d \
                --name pairings-api \
                -p 3000:3000 \
                -e RAILS_ENV=production \
                -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
                -e DATABASE_URL="postgres://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}" \
                ${var.ecr_image_url}
              
              # Wait for container to be ready
              echo "Waiting for container to be ready..."
              sleep 40
              
              echo "Running database migrations..."
              sudo docker exec pairings-api bin/rails db:migrate
              
              echo "User data script completed."
              EOF

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
