resource "aws_ecs_cluster" "main" {
    name = "${local.name}-cluster"
    setting {
      name = "containerInsight"
      value = "enabled"
    }
    tags = {
        Name = "${local.name}-cluster"
        }
}

resource "aws_cloudwatch_log_group" "ecs" {
    name = "/ecs/${local.name}"
    retention_in_days = 14
    tags = {
        Name = "${local.name}-ecs-logs"
        }
}

resource "aws_ecs_task_definition" "app" {
    family = "${local.name}-app"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = var.task_cpu
    memory = var.task_memory
    execution_role_arn = aws_iam_role.ecs_execution.arn
    task_role_arn = aws_iam_role.ecs_task.arn

    container_definitions = jsondecode([{
        name = "${local.name}-app"
        image = "${aws_ecr_repository.app.repository_url}:${var.app_version}"
        essential = true
        portMappings = [{
            containerPort = var.container_port,
            protocol = "tcp"
        }]
        environment = [{
            name = "APP_VERSION",
            value = var.app_version
        },
        {
            name = "ENVIRONMENT",
            value = var.environment
        },
        {
            name = "PORT",
            value = tostring(var.container_port)
        }]
        secrets = [{
            name = "DATABASE_URL",
            valueFrom = aws_secretsmanager_secret.db_credentials.arn
        }]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group" = aws_cloudwatch_log_group.ecs.name,
                "awslogs-region" = local.region,
                "awslogs-stream-prefix" = "app"
            }
        }
        healthCheck = {
            command = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/health')\" || exit 1"]
            interval = 30
            timeout = 5
            retries = 3
            startPeriod = 10
        }
    }])
}