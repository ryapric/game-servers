data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "backup" {
  bucket = local.backup_bucket_name
}
