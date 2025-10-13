output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_1a.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_1b.id
}
