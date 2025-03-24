resource "aws_rds_cluster" "aurora_serverless" {
  cluster_identifier      = "${var.environment}-aurora-serverless"
  engine                  = "aurora-postgresql"
  engine_mode             = "serverless"
  database_name           = "zantacdb"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 7
  preferred_backup_window = "03:00-05:00"
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.environment}-aurora-final-snapshot"
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [aws_security_group.aurora.id]

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 64
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = {
    Name        = "${var.environment}-aurora-serverless"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.environment}-aurora-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name        = "${var.environment}-aurora-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "aurora" {
  name        = "${var.environment}-aurora-sg"
  description = "Security group for Aurora Serverless"
  vpc_id      = aws_vpc.zantac_vpc.id

  ingress {
    description = "PostgreSQL from Lambda functions"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-aurora-sg"
    Environment = var.environment
  }
}