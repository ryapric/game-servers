# This Bucket is kept separate so that the rest of the resources can be
# created/destroyed without it. This Bucket should be deployed using local
# state, and then subsequently untracked so it persists
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "main" {
  bucket = "ryapric-game-servers-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  lifecycle_rule {
    id      = "Expire"
    enabled = true

    noncurrent_version_expiration {
      days = 3
    }
  }

  versioning {
    enabled = true
  }
}
