variable "s3_programmatic_users" {
  type = list(string)
  description = "Users who will access S3 programmatically"
  default = ["team"]
}

variable "s3_console_users" {
  type = list(string)
  description = "Users who will access S3 via Console"
  default = ["kate","chelsea"]
}

variable "s3_buckets" {
  type = list(string)
  description = "The list of S3 buckets to create for each environment"
  default = ["pie-app-prod", "pie-app-demo", "pie-app-staging", "pie-app-local"]
}

variable "wonderschool_necc_attendance_folders" {
  type        = list(string)
  description = "The list of S3 folders to create for Wonderschool Necc Attendances"
  default     = ["wonderschool", "wonderschool/necc", "wonderschool/necc/attendances", "wonderschool/necc/attendances/archive"]
}

locals {
  environment_bucket_list = setproduct(var.s3_buckets, var.wonderschool_necc_attendance_folders)
}