output "role" {
  description = "The id of the iam role used by the service"
  value       = aws_iam_role.main.id
}