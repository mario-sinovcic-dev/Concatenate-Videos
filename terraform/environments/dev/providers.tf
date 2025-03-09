provider "aws" {
  region = var.aws_region

  # Production-ready provider settings
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "video-processor"
      ManagedBy   = "terraform"
      Owner       = "platform-team"
    }
  }

  assume_role {
    role_arn = var.terraform_role_arn
  }
} 