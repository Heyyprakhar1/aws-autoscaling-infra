output "scale_up_policy_arn" {
  value = aws_autoscaling_policy.main.arn
}

output "scale_down_policy_arn" {
  value = aws_autoscaling_policy.scale_down.arn
}

output "asg_name" {
 value = aws_autoscaling_group.main.name
}
