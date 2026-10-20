output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "target_group_arn" {
  description = "ARN of the Application Load Balancer target group."
  value       = aws_lb_target_group.app.arn
}
