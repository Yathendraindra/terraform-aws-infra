output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_1a.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private_1b.id, aws_subnet.private_1c.id]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the public Route Table"
  value       = aws_route_table.public.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_eip" {
  description = "Elastic IP allocated to NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_servers.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.project_bucket.id
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.mysql_db.endpoint
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.mysql_db.port
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.app_lb.dns_name
}
