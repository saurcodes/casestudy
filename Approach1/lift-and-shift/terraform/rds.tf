# rds.tf - RDS for Oracle Database
resource "aws_db_subnet_group" "default" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "oracle" {
  identifier             = "${var.environment}-oracle-db"
  engine                 = "oracle-ee"
  engine_version         = "19.0.0.0.ru-2021-10.rur-2021-10.r1"
  instance_class         = "db.m5.large"
  allocated_storage      = 100
  storage_type           = "gp2"
  storage_encrypted      = true
  db_name                = "zantacdb"
  username               = var.db_username
  password               = var.db_password
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.environment}-oracle-final-snapshot"
  backup_retention_period = 7
  backup_window           = "03:00-05:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  deletion_protection     = true

  tags = {
    Name        = "${var.environment}-oracle-db"
    Environment = var.environment
  }
}