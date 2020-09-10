provider "aws" {
  region = "us-east-1"
}

data "aws_canonical_user_id" "current" {}

# 
resource "aws_s3_bucket" "terraform_state" {
  bucket = "benone-terraform-state-1"
  # acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }

  grant {
    id          = data.aws_canonical_user_id.current.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Lifecycle to reduce costs
  lifecycle_rule {
    prefix  = "workspace-develop/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "benone-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# ALB bucket logs
resource "aws_s3_bucket" "alb_logs_state" {
  bucket = "benone-web-servers-alb-logs"
  # acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }

  grant {
    id          = data.aws_canonical_user_id.current.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}