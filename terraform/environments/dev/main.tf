# Resource configurations for dev environment

# TODO - Create ECR / ECS Cluster / Task Definition / Service for running the service
# TODO - Networking - depends on existig infra
#        Use existing VPC and subnets if already created (import via data.tf)

# TODO - move all this to database module
# Generate random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${local.prefix}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
  })
}

module "database" {
  source = "../../modules/database"

  identifier        = "${local.prefix}-db"
  database_name     = "video_jobs"
  username         = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password         = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  environment      = local.environment
  
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnets
  allowed_security_groups = [module.ecs_cluster.security_group_id]

  # Production settings
  instance_class    = "db.t3.small"
  allocated_storage = 50
  
  tags = local.tags
}

# S3 bucket for video storage# S3 bucket for video storage
module "storage" {
  source = "../../modules/storage"

  environment = local.environment
}

# SQS queue for job processing
module "queue" {
  source = "../../modules/queue"

  environment = local.environment
}


