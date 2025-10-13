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
# Public Subnets
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
# Private Subnets
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
