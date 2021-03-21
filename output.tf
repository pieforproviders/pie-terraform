output "password" {
  value = [
    for human in var.humans:
    "aws_iam_user_login_profile.${human}.encrypted_password"
  ]
}

output "human_secrets" {
  value = [
    for human in var.humans:
    "aws_iam_access_key.${human}.encrypted_secret"
  ]
}

output "application_secrets" {
  value = [
    for application in var.applications:
    "aws_iam_access_key.${application}.encrypted_secret"
  ]
}
