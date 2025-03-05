module "storage" {
  source = "../../modules/storage"

  environment = "dev"
  db_username = var.db_username
  db_password = var.db_password
} 