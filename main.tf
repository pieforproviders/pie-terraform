# provider
provider "aws" {
  region = "us-east-2"
  profile = "pie"
}

# IAM configuration
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.master_account_id}:root"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.kate_account_id}:root", "arn:aws:iam::${var.chelsea_account_id}:root"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "admin" {
  name               = "admin"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "The role to grant permissions to this account to delegated IAM users in the master account"
}

resource "aws_iam_role_policy_attachment" "trust-attach" {
  role       = aws_iam_role.admin.name
  policy_arn = data.aws_iam_policy_document.trust_policy.json
}

# S3 resources
resource "aws_kms_key" "encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "production" {
  bucket = "pie-production"
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

resource "aws_s3_bucket_object" "production_wonderschool_necc_attendances" {
  count  = length(var.wonderschool_necc_attendance_folders)
  bucket = aws_s3_bucket.production.bucket
  acl    = "private"
  key    = "${var.wonderschool_necc_attendance_folders[count.index]}/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "production_wonderschool_necc_attendances_archive" {
  bucket = "pie-production"
  key    = "wonderschool/necc/attendances/archive/"
  source = "/dev/null"
}