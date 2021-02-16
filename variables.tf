variable "users" {
  type = list(string)
  description = "The list of IAM users for this organization"
  default = ["kate", "chelsea", "prod-app", "staging-app", "demo-app", "local-app"]
}

variable "app_environments" {
  type = list(string)
  description = "The list of environments the application has"
  default = ["prod", "demo", "staging", "local"]
}