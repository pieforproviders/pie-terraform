terraform {
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

provider "aws" {
  region  = "us-east-2"
  profile = "terraform"
  alias = "tech_team"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.tech_team.arn}:role/root"
  }
}

################
# Organization
################

resource "aws_organizations_organization" "pie" {
  # (organization arguments)
}

resource "aws_organizations_account" "tech_team" {
  name  = "tech_team"
  email = "team+tech@pieforproviders.com"
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
  provider = aws.tech_team
}

resource "aws_iam_user" "terraform" {
  name = "terraform"
  provider = aws.tech_team
}
resource "aws_iam_access_key" "terraform" {
  user = aws_iam_user.terraform.name
  provider = aws.tech_team
}

resource "aws_iam_user" "applications" {
  count = length(var.applications)
  name  = element(var.applications, count.index)
  provider = aws.tech_team
}
resource "aws_iam_access_key" "applications" {
  count = length(var.applications)
  user  = aws_iam_user.applications[count.index].name
  provider = aws.tech_team
}

resource "aws_iam_user" "humans" {
  count = length(var.humans)
  name  = element(var.humans, count.index)
  provider = aws.tech_team
}
resource "aws_iam_access_key" "humans" {
  count = length(var.humans)
  user  = aws_iam_user.humans[count.index].name
  provider = aws.tech_team
}
resource "aws_iam_user_login_profile" "example" {
  count   = length(var.humans)
  user    = aws_iam_user.humans[count.index].name
  pgp_key = "keybase:pieforproviders"
  provider = aws.tech_team
}

################
# Groups
################

resource "aws_iam_group_membership" "production_user_group_membership" {
  name  = "production_user_group_membership"
  users = concat(var.humans, ["production_app"])
  group = aws_iam_group.production_users.name
  provider = aws.tech_team
}

resource "aws_iam_group" "production_users" {
  name = "production_users"
  provider = aws.tech_team
}

resource "aws_iam_group_membership" "staging_user_group_membership" {
  name  = "staging_user_group_membership"
  users = concat(var.humans, ["staging_app"])
  group = aws_iam_group.staging_users.name
  provider = aws.tech_team
}

resource "aws_iam_group" "staging_users" {
  name = "staging_users"
  provider = aws.tech_team
}

resource "aws_iam_group_membership" "demo_user_group_membership" {
  name  = "demo_user_group_membership"
  users = concat(var.humans, ["demo_app"])
  group = aws_iam_group.demo_users.name
  provider = aws.tech_team
}

resource "aws_iam_group" "demo_users" {
  name = "demo_users"
  provider = aws.tech_team
}

resource "aws_iam_group_membership" "local_user_group_membership" {
  name  = "local_user_group_membership"
  users = concat(var.humans, ["local_app"])
  group = aws_iam_group.local_users.name
  provider = aws.tech_team
}

resource "aws_iam_group" "local_users" {
  name = "local_users"
  provider = aws.tech_team
}

################
# Policies - Production Buckets
################

data "aws_iam_policy_document" "production_buckets_policy_document" {
  statement {
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [aws_s3_bucket.production_log.arn, aws_s3_bucket.production.arn]
    effect    = "Allow"
  }
  provider = aws.tech_team
}

resource "aws_iam_group_policy" "production_buckets_policy" {
  name   = "production_buckets_policy"
  group  = aws_iam_group.production_users.name
  policy = data.aws_iam_policy_document.production_buckets_policy_document.json
  provider = aws.tech_team
}

################
# Policies - Staging Buckets
################

data "aws_iam_policy_document" "staging_buckets_policy_document" {
  statement {
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [aws_s3_bucket.staging_log.arn, aws_s3_bucket.staging.arn]
    effect    = "Allow"
  }
  provider = aws.tech_team
}

resource "aws_iam_group_policy" "staging_buckets_policy" {
  name   = "staging_buckets_policy"
  group  = aws_iam_group.staging_users.name
  policy = data.aws_iam_policy_document.staging_buckets_policy_document.json
  provider = aws.tech_team
}

################
# Policies - Demo Buckets
################

data "aws_iam_policy_document" "demo_buckets_policy_document" {
  statement {
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [aws_s3_bucket.demo_log.arn, aws_s3_bucket.demo.arn]
    effect    = "Allow"
  }
  provider = aws.tech_team
}

resource "aws_iam_group_policy" "demo_buckets_policy" {
  name   = "demo_buckets_policy"
  group  = aws_iam_group.demo_users.name
  policy = data.aws_iam_policy_document.demo_buckets_policy_document.json
  provider = aws.tech_team
}

################
# Policies - Local Buckets
################

data "aws_iam_policy_document" "local_buckets_policy_document" {
  statement {
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [aws_s3_bucket.local_log.arn, aws_s3_bucket.local.arn]
    effect    = "Allow"
  }
  provider = aws.tech_team
}

resource "aws_iam_group_policy" "local_buckets_policy" {
  name   = "local_buckets_policy"
  group  = aws_iam_group.local_users.name
  policy = data.aws_iam_policy_document.local_buckets_policy_document.json
  provider = aws.tech_team
}

################
# Buckets
################

resource "aws_s3_bucket" "production_log" {
  bucket = "production_log"
  acl    = "log-delivery-write"
  provider = aws.tech_team
}

resource "aws_kms_key" "production" {
  description             = "Key to encrypt production bucket"
  deletion_window_in_days = 10
  provider = aws.tech_team
}

resource "aws_s3_bucket" "production" {
  bucket = "production"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.production_log.id
    target_prefix = "log/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.production.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  provider = aws.tech_team
}

resource "aws_s3_bucket" "staging_log" {
  bucket = "staging_log"
  acl    = "log-delivery-write"
  provider = aws.tech_team
}

resource "aws_kms_key" "staging" {
  description             = "Key to encrypt staging bucket"
  deletion_window_in_days = 10
  provider = aws.tech_team
}

resource "aws_s3_bucket" "staging" {
  bucket = "staging"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.staging_log.id
    target_prefix = "log/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.staging.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  provider = aws.tech_team
}

resource "aws_s3_bucket" "demo_log" {
  bucket = "demo_log"
  acl    = "log-delivery-write"
  provider = aws.tech_team
}

resource "aws_kms_key" "demo" {
  description             = "Key to encrypt demo bucket"
  deletion_window_in_days = 10
  provider = aws.tech_team
}

resource "aws_s3_bucket" "demo" {
  bucket = "demo"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.demo_log.id
    target_prefix = "log/"
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.demo.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  provider = aws.tech_team
}

resource "aws_s3_bucket" "local_log" {
  bucket = "local_log"
  acl    = "log-delivery-write"
  provider = aws.tech_team
}

resource "aws_kms_key" "local" {
  description             = "Key to encrypt local bucket"
  deletion_window_in_days = 10
  provider = aws.tech_team
}

resource "aws_s3_bucket" "local" {
  bucket = "local"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.local_log.id
    target_prefix = "log/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.local.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  provider = aws.tech_team
}