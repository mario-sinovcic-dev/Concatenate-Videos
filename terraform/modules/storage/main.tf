# S3 for video storage
resource "aws_s3_bucket" "videos" {
  bucket = "local-video-storage"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "videos" {
  bucket = aws_s3_bucket.videos.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "videos" {
  bucket = aws_s3_bucket.videos.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "videos" {
  depends_on = [
    aws_s3_bucket_ownership_controls.videos,
    aws_s3_bucket_public_access_block.videos,
  ]

  bucket = aws_s3_bucket.videos.id
  acl    = "public-read-write"
}

# SQS for job processing # TODO - add this back
# resource "aws_sqs_queue" "jobs" {
#   name = "${var.environment}-video-jobs"
#   visibility_timeout_seconds = 300
#   message_retention_seconds = 86400
# }