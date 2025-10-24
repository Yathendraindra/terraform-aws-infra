# -------------------------------
# VPC Configuration
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "main-vpc"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Public Subnet (ap-south-1a)
# -------------------------------
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-subnet-1a"
    Project = "terraform-aws-infra"
    Type    = "public"
  }
}

# -------------------------------
# Private Subnet (ap-south-1b)
# -------------------------------
resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name    = "private-subnet-1b"
    Project = "terraform-aws-infra"
    Type    = "private"
  }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "main-igw"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Public Route Table
# -------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "public-rt"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Associate Route Table with Public Subnet
# -------------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# -------------------------------
# Elastic IP for NAT Gateway
# -------------------------------
resource "aws_eip" "nat" {
  tags = {
    Name    = "nat-eip"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# NAT Gateway in Public Subnet
# -------------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name    = "nat-gateway"
    Project = "terraform-aws-infra"
  }

  depends_on = [aws_internet_gateway.igw]
}

# -------------------------------
# Private Route Table
# -------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "private-rt"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Associate Private Subnet with Private Route Table
# -------------------------------
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}

# -------------------------------
# Security Group for EC2
# -------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "web_sg"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# EC2 Instance in Public Subnet
# -------------------------------
resource "aws_instance" "web_servers" {
  ami                         = "ami-0dee22c13ea7a9a67"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1a.id
  key_name                    = "devops-demo"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "web_server"
    Project = "terraform-aws-infra"
  }
}

