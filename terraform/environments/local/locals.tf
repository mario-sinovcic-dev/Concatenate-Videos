locals {
  environment = "local"
  prefix     = "video-processor-${local.environment}"

  tags = { # TODO: create a shared config for tags
    Environment = local.environment
    Project     = "video-processor"
    ManagedBy   = "terraform"
  }
} 