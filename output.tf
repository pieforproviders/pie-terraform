# output "password" {
#   count = length(var.users)
#   value = "aws_iam_user_login_profile.${element(var.users, count.index)}.encrypted_password"
# }

# output "secret" {
#   value = "aws_iam_access_key.${element(var.users, count.index)}.encrypted_secret"
# }
output "accounts" {
  value = aws_organizations_organization.pie.accounts
}

# output "iam_groups" {
#   value = aws.users
# }