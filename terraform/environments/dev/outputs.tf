output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = module.database.endpoint
}

output "database_name" {
  description = "Name of the database"
  value       = module.database.database_name
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = module.queue.queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = module.queue.queue_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.storage.bucket_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
} 