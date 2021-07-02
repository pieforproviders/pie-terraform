variable "humans" {
  type        = list(string)
  description = "The list of human IAM users for this organization"
  default     = ["kate", "chelsea"]
}