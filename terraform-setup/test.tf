# Test instances
# resource "aws_instance" "test_frontend" {
#   ami           = data.aws_ami.amazon_linux_2023.id
#   instance_type = var.ami_type

#   vpc_security_group_ids = [aws_security_group.frontend.id]
#   subnet_id              = aws_subnet.public.id

#   tags = {
#     Name = "test-frontend"
#   }
# }

# resource "aws_instance" "test_backend" {
#   ami           = data.aws_ami.amazon_linux_2023.id
#   instance_type = var.ami_type

#   vpc_security_group_ids = [aws_security_group.backend.id]
#   subnet_id              = aws_subnet.public.id

#   tags = {
#     Name = "test-backend"
#   }
# }

# # Outputs for testing
# output "test_results" {
#   value = {
#     frontend_sg_id = aws_security_group.frontend.id
#     backend_sg_id  = aws_security_group.backend.id
#     frontend_ip    = aws_instance.test_frontend.private_ip
#     backend_ip     = aws_instance.test_backend.private_ip
#     frontend_ports = "80,443"
#     backend_ports  = "22,3000"
#   }
# }
