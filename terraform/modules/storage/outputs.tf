output "s3_bucket" {
  value = aws_s3_bucket.videos.bucket
}

# output "sqs_queue_url" {
#   value = aws_sqs_queue.jobs.url
# }