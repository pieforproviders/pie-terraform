output "role_name" {
  value       = aws_iam_role.admin.name
  description = "The name of the created role"
}

output "role_id" {
  value       = aws_iam_role.admin.unique_id
  description = "The stable and unique string identifying the role"
}

output "role_arn" {
  value       = aws_iam_role.admin.arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}