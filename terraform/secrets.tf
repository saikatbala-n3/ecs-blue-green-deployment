resource "random_password" "db_password" {
    length = 32
    special = false
}

resource "aws_secretsmanager_secret" "db_credentials" {
    name = "${local.name}-db-credentials"
    recovery_window_in_days = 0
    tags = {
        Name = "${local.name}-db-credentials"
    }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
    secret_id = aws_secretsmanager_secret.db_credentials.id
    secret_string = jsondecode({
        username = var.db_username
        password = random_password.db_password.result
        host = aws_db_instance.main.address
        port = 5432
        dbname = var.db_name
        url = "postgresql://${var.db_username}:${random_password.db_password.result}@${aws_db_instance.main.address}:5432/${var.db_name}"
    })
}