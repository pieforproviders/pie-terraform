
variable "master_account_id" {
  type        = string
  description = "The ID of the master account"
  # sensitive   = true
}

variable "kate_account_id" {
  type        = string
  description = "The ID of Kate's account to grant permissions to access the current role"
  # sensitive   = true
}

variable "chelsea_account_id" {
  type        = string
  description = "The ID of Chelsea's account to grant permissions to access the current role"
  # sensitive   = true
}