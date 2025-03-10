# Resource configurations for local environment

# module "database" {
#   source = "../../modules/database"

#   identifier        = "${local.prefix}-db"
#   database_name     = "video_jobs"
#   username         = var.db_username
#   password         = var.db_password
#   environment      = local.environment
  
#   # LocalStack dummy values since we're using real PostgreSQL container
#   vpc_id                  = "vpc-dummy"
#   subnet_ids              = ["subnet-dummy1", "subnet-dummy2"]
#   allowed_security_groups = []
  
#   tags = local.tags
# }

# S3 bucket for video storage
module "storage" {
  source = "../../modules/storage"

  environment = local.environment
}


# TODO: Add queue module for SQS
# TODO: Add compute module for ECS/Fargate
