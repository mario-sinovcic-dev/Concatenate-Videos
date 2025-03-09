# S3 for video storage
resource "aws_s3_bucket" "videos" {
  bucket = "${var.environment}-video-storage"
}

# SQS for job processing
resource "aws_sqs_queue" "jobs" {
  name = "${var.environment}-video-jobs"
  visibility_timeout_seconds = 300
  message_retention_seconds = 86400
}