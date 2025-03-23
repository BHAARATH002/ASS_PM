# Security Group for RDS
data "aws_security_group" "ec2_sg" {
  filter {
    name   = "group-name"
    values = ["web-security-group"]  # Replace with actual EC2 SG name
  }
}

data "aws_security_group" "bastion_sg" {
  filter {
    name   = "group-name"
    values = ["bastion-sg"]  # Replace with actual EC2 SG name
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow MySQL connections"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [data.aws_security_group.ec2_sg.id, data.aws_security_group.bastion_sg.id]  # Allow only from EC2
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}