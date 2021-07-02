terraform {
  backend "s3" {
    bucket = "p4p-terraform-state"
    region = "us-east-2"
    profile = "terraform"
    key = "state"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "terraform"
}

################
# Local Variables
################

locals {
  environments = {
    production = {}
    staging    = {}
    demo       = {}
    local      = {}
  }
}

################
# Users
################

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_user" "applications" {
  for_each = local.environments
  name     = each.key
}
resource "aws_iam_access_key" "applications" {
  for_each = local.environments
  user     = aws_iam_user.applications[each.key].name
  pgp_key  = "keybase:pieforproviders"
}

resource "aws_iam_user" "humans" {
  for_each = toset(var.humans)
  name     = each.key
}
resource "aws_iam_access_key" "humans" {
  for_each = toset(var.humans)
  user     = aws_iam_user.humans[each.key].name
  pgp_key  = "keybase:pieforproviders"
}
resource "aws_iam_user_login_profile" "humans" {
  for_each                = toset(var.humans)
  user                    = aws_iam_user.humans[each.key].name
  pgp_key                 = "keybase:pieforproviders"
  password_reset_required = true
}

################
# Groups
################

resource "aws_iam_group_membership" "user_group_membership" {
  for_each = local.environments
  name     = "${each.key}_user_group_membership"
  users    = concat(var.humans, [each.key])
  group    = aws_iam_group.users[each.key].name
}

resource "aws_iam_group" "users" {
  for_each = local.environments
  name     = each.key
}

data "aws_iam_policy_document" "buckets_policy_document" {
  for_each = local.environments
  statement {
    actions = [
      "s3:*"
    ]
    resources = [aws_s3_bucket.log_bucket.arn, aws_s3_bucket.environment_buckets[each.key].arn,aws_s3_bucket.archive_buckets[each.key].arn]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketAcl",
      "s3:ListAccessPoints"
    ]
    resources = ["arn:aws:s3:::*"]
    effect    = "Allow"
  }
}

resource "aws_iam_group_policy" "buckets_policy" {
  for_each = local.environments
  name     = "${each.key}_bucket_policy"
  group    = aws_iam_group.users[each.key].name
  policy   = data.aws_iam_policy_document.buckets_policy_document[each.key].json
}


resource "aws_s3_bucket" "log_bucket" {
  bucket = "p4p-logs"
  acl    = "log-delivery-write"
}

resource "aws_kms_key" "kms_keys" {
  for_each                = local.environments
  description             = "Key to encrypt ${each.key} bucket"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "environment_buckets" {
  for_each = local.environments
  bucket   = "${each.key}-p4p"
  acl      = "private"

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "${each.key}/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_keys[each.key].arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket" "archive_buckets" {
  for_each = local.environments
  bucket   = "${each.key}-p4p-archive"
  acl      = "private"

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "${each.key}-archive/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_keys[each.key].arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "archive_block" {
  for_each                = local.environments
  bucket                  = aws_s3_bucket.archive_buckets[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "environment_block" {
  for_each                = local.environments
  bucket                  = aws_s3_bucket.environment_buckets[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "log_block" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}