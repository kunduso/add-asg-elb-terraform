
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
  #   ingress {
  #     protocol  = "-1"
  #     self      = true
  #     from_port = 0
  #     to_port   = 0
  #   }

  #   egress {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }
  tags = {
    "Name" = "${var.name}-default-sg"
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = "${var.name}-Instance-SG"
  description = "Allow inbound and outbound traffic to EC2 instances from load balancer security group"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.asg_lb_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-instance-sg"
  }
}

resource "aws_security_group" "asg_lb_security_group" {
  description = "Allow inbound and outbound traffic to load balancer from the internet."
  name        = "${var.name}-ASG-LB-SG-IN"
  ingress {
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
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-asg-lb-sg"
  }
}