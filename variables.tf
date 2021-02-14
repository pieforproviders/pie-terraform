
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

variable "wonderschool_necc_attendance_folders" {
  type        = list(string)
  description = "The list of S3 folders to create for Wonderschool Necc Attendances"
  default     = ["wonderschool", "wonderschool/necc", "wonderschool/necc/attendances", "wonderschool/necc/attendances/archive"]
}