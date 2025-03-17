resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server"
  image_id      = "ami-12345678"  # Replace with latest Amazon Linux AMI
  instance_type = "t3.micro"
  key_name      = "your-key"  # Replace with your key pair
  user_data     = base64encode("#!/bin/bash\nyum install -y httpd\nservice httpd start")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  min_size = 1
  max_size = 2
  desired_capacity = 1

  vpc_zone_identifier = ["subnet-12345678", "subnet-87654321"]
}

resource "aws_lb" "web_elb" {
  name               = "web-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets           = ["subnet-12345678", "subnet-87654321"]
}

resource "aws_lb_target_group" "tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-12345678"
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.tg.arn
}

