output "lb_endpoint" {
  value = "http://${aws_lb.front.dns_name}"
}