output "api_instance_id" {
  description = "ID of the API EC2 instance"
  value       = aws_instance.backend.id
}

output "api_instance_public_ip" {
  description = "Public IP address of the API EC2 instance"
  value       = aws_instance.backend.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.api.dns_name
}

output "database_endpoint" {
  description = "The database endpoint"
  value       = aws_db_instance.postgres.endpoint
  sensitive   = true
}
