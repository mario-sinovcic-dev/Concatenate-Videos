locals {
  environment = "dev"
  prefix     = "video-processor-${local.environment}"

  tags = {
    Environment = local.environment
    Project     = "video-processor"
    ManagedBy   = "terraform"
  }
} 