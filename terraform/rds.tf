resource "aws_db_subnet_group" "main" {
    name = "${local.name}-db-subnet"
    subnet_ids = aws_subnet.private[*].id
    tags = {
      Name = "${local.name}-db-subnet"
    }
}

resource "aws_db_instance" "main" {
    identifier = "${local.name}-db"
    engine = "postgres"
    engine_version = "15.4"
    instance_class = var.db_instance_class
    db_name = var.db_name
    username = var.db_username
    password = random_password.db_password.result

    allocated_storage = 20
    max_allocated_storage = 50
    storage_type = "gp3"
    storage_encrypted = true

    multi_az = false
    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.rds.id]

    backup_retention_period = 7
    skip_final_snapshot = true
    deletion_protection = false

    tags = {
      Name = "${local.name}-db"
    }
}