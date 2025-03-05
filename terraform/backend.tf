terraform {
  backend "s3" {
    # Configure these via CLI or environment variables
    # bucket = "your-terraform-state"
    # key    = "video-service/terraform.tfstate"
    # region = "us-east-1"
  }
} 