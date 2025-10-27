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

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-subnet-1b"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Private Subnet (ap-south-1a)
# -------------------------------
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name    = "private-subnet-1a"
    Project = "terraform-aws-infra"
    Type    = "private"
  }
}

# -------------------------------
# Private Subnet (ap-south-1b)
# -------------------------------
resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name    = "private-subnet-1b"
    Project = "terraform-aws-infra"
    Type    = "private"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name    = "private-subnet-1c"
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

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_1b.id
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
# Associate Private Subnets with Private Route Table
# -------------------------------
resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_assoc_b" {
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
  iam_instance_profile        = aws_iam_instance_profile.ec2_s3_profile.name

  tags = {
    Name    = "web_server"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Random ID for unique bucket name
# -------------------------------
resource "random_id" "bucket_id" {
  byte_length = 4
}

# -------------------------------
# S3 Bucket
# -------------------------------
resource "aws_s3_bucket" "project_bucket" {
  bucket = "terraform-aws-infra-bucket-${random_id.bucket_id.hex}"

  tags = {
    Name    = "terraform-aws-infra-bucket"
    Project = "terraform-aws-infra"
  }
}
# -------------------------------
# Enable Versioning for S3 Bucket
# -------------------------------
resource "aws_s3_bucket_versioning" "project_bucket_versioning" {
  bucket = aws_s3_bucket.project_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------------
# IAM Role for EC2 to access S3
# -------------------------------
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# -------------------------------
# Attach S3 policy
# -------------------------------
resource "aws_iam_role_policy_attachment" "ec2_s3_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# -------------------------------
# Instance Profile for EC2
# -------------------------------
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_role.name
}

# -------------------------------
# Security Group for RDS
# -------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow MySQL access from EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL from web server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # only EC2 can access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "rds_sg"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# RDS Subnet Group
# -------------------------------
resource "aws_db_subnet_group" "rds_subnets" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id,
    aws_subnet.private_1c.id
  ]

  tags = {
    Name    = "rds-subnet-group"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# RDS MySQL Instance
# -------------------------------
resource "aws_db_instance" "mysql_db" {
  identifier             = "terraform-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "admin"
  password               = "Admin1234!" # use sensitive vars in production
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name    = "terraform-db"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Security Group for ALB
# -------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow inbound HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
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
    Name    = "alb_sg"
    Project = "terraform-aws-infra"
  }
}

# -------------------------------
# Target Group for EC2 instances
# -------------------------------

resource "aws_lb_target_group" "web_tg" {
  name        = "web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name    = "web-tg"
    Project = "terraform-aws-infra"
  }

}

# -------------------------------
# Application Load Balancer (ALB)
# -------------------------------
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]

  tags = {
    Name    = "app-lb"
    Project = "terraform-aws-infra"
  }
}


# -------------------------------
# ALB Listener
# -------------------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

}

# -------------------------------
# Attach EC2 Instance to Target Group
# -------------------------------
resource "aws_lb_target_group_attachment" "web_tg_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_servers.id
  port             = 80
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name    = "app-tg"
    Project = "terraform-aws-infra"
  }
}

resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web_servers.id
  port             = 80
}