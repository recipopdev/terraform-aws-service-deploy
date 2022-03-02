output "security_group" {
  description = "The security group attached to the service"
  value       = aws_security_group.main.id
}