output "role" {
  description = "The id of the iam role used by the service"
  value       = aws_iam_role.main.id
}

output "security_group" {
  description = "The id of the security group used by the service"
  value       = aws_security_group.main.id
}
