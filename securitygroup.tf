
resource "aws_security_group" "ec2_security_group" {
  name = "Instance-SG"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.asg_lb_security_group.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.this.id
    tags = {
    "Name" = "app-1-instance-sg"
  }
}

resource "aws_security_group" "asg_lb_security_group" {
  name = "ASG-LB-SG"
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
    "Name" = "app-1-asg-lb-sg"
  }
}