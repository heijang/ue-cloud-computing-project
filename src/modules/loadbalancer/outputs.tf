output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_sg_id" {
  description = "Security group ID of the ALB (used by web tier SG ingress)."
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the ALB target group (used by ASG)."
  value       = aws_lb_target_group.web.arn
}
