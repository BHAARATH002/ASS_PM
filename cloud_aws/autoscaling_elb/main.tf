# Fetch the VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]  # Change this to your VPC name or use VPC ID directly
  }
}

# Get all subnets in the VPC
data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Fetch the public route table (one that has a route to IGW)
data "aws_route_table" "public_rt" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "route.gateway-id"
    values = ["igw-06c0e2f2a85adf3a4"]  # Replace with your IGW ID
  }
}

# Fetch public subnets (subnets associated with the public route table)
data "aws_subnet" "public_subnets" {
  count = length(data.aws_subnets.all_subnets.ids)
  
  id = data.aws_subnets.all_subnets.ids[count.index]
}

data "aws_security_group" "web_sg" {
  filter {
    name   = "group-name"
    values = ["web-security-group"]  # Replace with actual EC2 SG name
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server"
  image_id      = data.aws_ami.amazon_linux.id  # Dynamically fetch AMI
  instance_type = "t3.micro"
  key_name      = "control"  # Replace with your key pair
  user_data     = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              echo "<h1>Hello, World! from $(hostname -f)</h1>" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.web_sg.id]
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "WebServerInstance"
      Owner       = "Bhaarathan"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  min_size = 1
  max_size = 1
  desired_capacity = 1

  vpc_zone_identifier = [for s in data.aws_subnet.public_subnets : s.id]
}

resource "aws_lb" "web_elb" {
  name               = "web-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.web_sg.id]
  subnets           = [for s in data.aws_subnet.public_subnets : s.id]
}

resource "aws_lb_target_group" "tg_80" {
  name     = "web-target-group-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
}

# Target Group for port 8080
resource "aws_lb_target_group" "tg_8080" {
  name     = "web-target-group-8080"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
}

resource "aws_lb_listener" "web_listener_80" {
  load_balancer_arn = aws_lb.web_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_80.arn
  }
}

resource "aws_lb_listener" "web_listener_8080" {
  load_balancer_arn = aws_lb.web_elb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_8080.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_80" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.tg_80.arn
}
resource "aws_autoscaling_attachment" "asg_attachment_8080" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.tg_8080.arn
}
