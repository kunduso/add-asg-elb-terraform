data "aws_ami" "amazon_ami" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20220606.1-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["amazon"]
}
resource "aws_launch_template" "application" {
  image_id        = data.aws_ami.amazon_ami.id
  instance_type   = "t2.small"
  user_data       = filebase64("./user_data/user_data.tpl")
  network_interfaces {
    #associate_public_ip_address = true
    security_groups = [aws_security_group.ec2_security_group.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "application" {
  name                 = "app-one"
  min_size             = 3
  max_size             = 6
  desired_capacity     = 3
  launch_template {
    id      = aws_launch_template.application.id
    version = "$Latest"
  }
  vpc_zone_identifier  = aws_subnet.public.*.id

  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "app-one"
    propagate_at_launch = true
  }
}