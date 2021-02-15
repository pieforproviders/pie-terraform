# Provider
provider "aws" {
  region = "us-east-2"
  profile = "terraform"
}

# Organization

resource "aws_organizations_organization" "pie" {
  # (resource arguments)
}



# IAM

resource "aws_iam_user" "users" {
  count = length(concat(var.s3_console_users, var.s3_programmatic_users))
  name = element(concat(var.s3_console_users, var.s3_programmatic_users), count.index)
}

# S3 Programmatic

data "aws_iam_policy_document" "s3_programmatic_policy_document" {
  statement {
    actions = ["s3:*"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "s3_programmatic_policy" {
  name = "s3_programmatic"
  policy = data.aws_iam_policy_document.s3_programmatic_policy_document.json
}

resource "aws_iam_user_policy_attachment" "s3_programmatic_attach" {
  count = length(var.s3_programmatic_users)
  user = element(var.s3_programmatic_users, count.index)
  policy_arn = aws_iam_policy.s3_programmatic_policy.arn
}

# S3 Console Access

data "aws_iam_policy_document" "s3_console_policy_document" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "s3_console_policy" {
  name = "s3_console"
  policy = data.aws_iam_policy_document.s3_console_policy_document.json
}

resource "aws_iam_user_policy_attachment" "s3_console_attach" {
  count = length(var.s3_console_users)
  user = element(var.s3_console_users, count.index)
  policy_arn = aws_iam_policy.s3_console_policy.arn
}

# S3 Buckets

resource "aws_kms_key" "encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "buckets" {
  count = length(var.s3_buckets)
  bucket = element(var.s3_buckets, count.index)
  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.encryption_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# S3 Folders

resource "aws_s3_bucket_object" "wonderschool_necc_attendances" {
  count  = length(local.environment_bucket_list[0])
  bucket = element(local.environment_bucket_list, count.index)[0]
  acl    = "private"
  key    = element(local.environment_bucket_list, count.index)[1]
  source = "/dev/null"
}