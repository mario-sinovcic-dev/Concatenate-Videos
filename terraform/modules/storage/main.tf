# S3 for video storage
# TODO: WARN currently this module is unsecure, should not be used in envs other than local

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

  block_public_acls       = var.environment != "local"
  block_public_policy     = var.environment != "local"
  ignore_public_acls      = var.environment != "local"
  restrict_public_buckets = var.environment != "local"
}

resource "aws_s3_bucket_acl" "videos" {
  depends_on = [
    aws_s3_bucket_ownership_controls.videos,
    aws_s3_bucket_public_access_block.videos,
  ]

  # TODO: WARN currently this is unsecure, should not be used in envs other than local
  bucket = aws_s3_bucket.videos.id
  acl    = "public-read-write" 
}