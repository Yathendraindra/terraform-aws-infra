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

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the public Route Table"
  value       = aws_route_table.public.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_servers.public_ip
}