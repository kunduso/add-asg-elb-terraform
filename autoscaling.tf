data "aws_ami" "amazon_ami" {
  filter {
    name   = "name"
    values = var.ami_name
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["amazon"]
}
resource "aws_launch_template" "application" {
  image_id      = data.aws_ami.amazon_ami.id
  instance_type = var.instance_type
  user_data     = filebase64("./user_data/user_data.tpl")
  network_interfaces {
    security_groups = [aws_security_group.ec2_security_group.id]
  }
  iam_instance_profile {
    name = "ec2_profile"
  }
}

resource "aws_autoscaling_group" "application" {
  name                      = "app-3"
  min_size                  = 3
  max_size                  = 6
  desired_capacity          = 3
  health_check_grace_period = 480
  launch_template {
    id      = aws_launch_template.application.id
    version = aws_launch_template.application.latest_version
  }
  vpc_zone_identifier = aws_subnet.private.*.id
  health_check_type   = "ELB"
  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      skip_matching          = true
    }
    triggers = ["launch_template"]
  }
  tag {
    key                 = "Name"
    value               = "app-3"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asg_policy_up" {
  name                   = "asg_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.application.name
}
resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm_up" {
  alarm_name          = "asg_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.application.name}"
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asg_policy_up.arn]
}

resource "aws_autoscaling_policy" "asg_policy_down" {
  name                   = "asg_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.application.name
}
resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm_down" {
  alarm_name          = "asg_cpu_alarm_down"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.application.name}"
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asg_policy_down.arn]
}