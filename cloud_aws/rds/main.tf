data "aws_security_group" "rds_sg" {
  filter {
    name   = "group-name"
    values = ["rds-security-group"]  # Replace with actual EC2 SG name
  }
}
# Get the default VPC ID
data "aws_vpc" "default" {
  default = true
}

# Get the subnets in the default VPC (ensure these exist in different AZs)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create an RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "intruder-detection-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids  # Uses all subnets in the default VPC

  tags = {
    Name = "Intruder Detection DB Subnet Group"
  }
}

resource "aws_db_instance" "rds" {
  identifier           = "intruder-detection-db"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username           = "admin"
  password           = "930485bd7ncxbh"
  publicly_accessible = true
  multi_az           = true
  vpc_security_group_ids = [data.aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "Intruder Detection RDS"
  }
}
