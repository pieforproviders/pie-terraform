output "human_passwords" {
  value = [
    for login in aws_iam_user_login_profile.humans :
    { password = login.encrypted_password
    user = login.user }
  ]
}

output "human_secrets" {
  value = [
    for access_key in aws_iam_access_key.humans :
    { secret = access_key.encrypted_secret
    user = access_key.user }
  ]
}

output "application_secrets" {
  value = [
    for access_key in aws_iam_access_key.applications :
    { secret = access_key.encrypted_secret
    user = access_key.user }
  ]
}
