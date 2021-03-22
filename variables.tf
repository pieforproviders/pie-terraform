variable "humans" {
  type = list(string)
  description = "The list of human IAM users for this organization"
  default = ["kate", "chelsea"]
}

variable "applications" {
  type = list(string)
  description = "The list of application IAM users for this organization"
  default = ["production_app", "staging_app", "demo_app", "local_app"]
}