output "alb_dns_name" {
    description = "ALB DNS name (production)"
    value       = aws_lb.main.dns_name
}

output "alb_test_url" {
    description = "ALB test listener URL"
    value       = "http://${aws_lb.main.dns_name}:8080"
}

output "ecr_repository_url" {
    value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
    value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
    value = aws_ecs_service.app.name
}

output "codedeploy_app_name" {
    value = aws_codedeploy_app.ecs.name
}

output "rds_endpoint" {
    value = aws_db_instance.main.endpoint
}

output "github_actions_role_arn" {
    value = aws_iam_role.github_actions.arn
}