output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_1_id" {
  description = "Public subnet 1 ID"
  value       = aws_subnet.public_1.id
}

output "subnet_2_id" {
  description = "Public subnet 2 ID"
  value       = aws_subnet.public_2.id
}

output "availability_zones" {
  description = "Availability zones used"
  value = [
    aws_subnet.public_1.availability_zone,
    aws_subnet.public_2.availability_zone
  ]
}

output "server_1_public_ip" {
  description = "Public IP of EC2 server 1"
  value       = aws_instance.web_1.public_ip
}

output "server_2_public_ip" {
  description = "Public IP of EC2 server 2"
  value       = aws_instance.web_2.public_ip
}

output "server_1_url" {
  description = "URL of server 1"
  value       = "http://${aws_instance.web_1.public_ip}"
}

output "server_2_url" {
  description = "URL of server 2"
  value       = "http://${aws_instance.web_2.public_ip}"
}