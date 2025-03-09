resource "aws_db_instance" "postgres" {
  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.database_name
  username = var.username
  password = var.password

  vpc_security_group_ids = [aws_security_group.postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name

  backup_retention_period = var.environment == "local" ? 0 : 7
  skip_final_snapshot    = var.environment == "local"

  tags = var.tags
}

resource "aws_security_group" "postgres" {
  name_prefix = "${var.identifier}-postgres-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  tags = var.tags
}

resource "aws_db_subnet_group" "postgres" {
  name_prefix = "${var.identifier}-"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
} 