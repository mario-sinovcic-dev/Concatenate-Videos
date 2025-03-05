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

# RDS for job metadata
resource "aws_db_instance" "jobs" {
  identifier        = "${var.environment}-video-jobs"
  engine           = "postgres"
  engine_version   = "14"
  instance_class   = "db.t4g.micro"
  allocated_storage = 20

  db_name  = "video_jobs"
  username = var.db_username
  password = var.db_password

  skip_final_snapshot = true
} 