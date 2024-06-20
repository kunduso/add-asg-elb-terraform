
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-default-sg"
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "ec2_security_group" {
  name        = "${var.name}-Instance-SG"
  description = "Allow inbound and outbound traffic to EC2 instances from load balancer security group"
  vpc_id      = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-instance-sg"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_ec2" {
  description              = "allow traffic from the load balancer"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_lb_security_group.id
  security_group_id        = aws_security_group.ec2_security_group.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress_ec2" {
  description       = "allow traffic to the load balancer"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_security_group.id
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "asg_lb_security_group" {
  description = "Allow inbound and outbound traffic to load balancer from the internet."
  name        = "${var.name}-ASG-LB-SG-IN"
  vpc_id      = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-asg-lb-sg"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_load_balancer" {
  description       = "Allow traffic into the load balancer from the internet."
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg_lb_security_group.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress_load_balancer" {
  description       = "Allow traffic to reach outside the vpc."
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg_lb_security_group.id
}