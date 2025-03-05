output "s3_bucket" {
  value = aws_s3_bucket.videos.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.jobs.url
}

output "db_endpoint" {
  value = aws_db_instance.jobs.endpoint
}

output "db_name" {
  value = aws_db_instance.jobs.db_name
} 