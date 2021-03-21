output "password" {
  count = length(var.users)
  value = "aws_iam_user_login_profile.${element(var.users, count.index)}.encrypted_password"
}

output "secret" {
  value = "aws_iam_access_key.${element(var.users, count.index)}.encrypted_secret"
}