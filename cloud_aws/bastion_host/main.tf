# Get the latest Amazon Linux 2 AMI ID
data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create a new EC2 key pair
resource "aws_key_pair" "control" {
  key_name   = "control"
  public_key = tls_private_key.control.public_key_openssh
}

# Generate a private key
resource "tls_private_key" "control" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a file
resource "local_file" "control_key" {
  content  = tls_private_key.control.private_key_pem
  filename = "control.pem"
}

# VPC Data Source (assuming you already have a VPC)
data "aws_vpc" "default" {
  default = true
}

# Subnet Data Source (assuming you have a public subnet)
data "aws_subnet" "public" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1a" # Change to your preferred AZ
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Fetch existing security groups
data "aws_security_group" "rds_sg" {
  filter {
    name   = "group-name"
    values = ["rds-security-group"]  # Replace with actual EC2 SG name
  }
}

data "aws_security_group" "web_sg" {
  filter {
    name   = "group-name"
    values = ["web-security-group"]  # Replace with actual EC2 SG name
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH access to Bastion Host"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from any IP (restrict this later)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}

# EC2 Instance for Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2.value # Use the latest Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id, data.aws_security_group.web_sg.id, data.aws_security_group.rds_sg.id]
  key_name               = aws_key_pair.control.key_name # Use the created key pair

  tags = {
    Name = "Bastion-Host"
  }
}

# Outputs
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "latest_amazon_linux_2_ami" {
  value = data.aws_ssm_parameter.amazon_linux_2.value
  sensitive = true
}

output "private_key" {
  value     = tls_private_key.control.private_key_pem
  sensitive = true
}