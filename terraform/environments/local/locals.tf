locals {
  environment = "local"
  prefix     = "video-processor-${local.environment}"

  tags = {
    Environment = local.environment
    Project     = "video-processor"
    ManagedBy   = "terraform"
  }
} 