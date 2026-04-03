resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name = "${local.name}-cpu-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/ECS"
    period = 60
    statistic = "Average"
    threshold = 85
    alarm_description = "ECS CPU > 85% for 2 minutes"
    dimensions = {
        ClusterName = aws_ecs_cluster.main.name,
        ServiceName = aws_ecs_service.main.name
    }
    alarm_actions = [aws_sns_topic.alerts.arn]
    ok_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
    alarm_name = "${local.name}-alb-5xx"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1
    metric_name = "HTTPCode_Target_5XX_Count"
    namespace = "AWS/ApplicationELB"
    period = 60
    statistic = "Sum"
    threshold = 10
    alarm_description = "ALB 5xx > 10 in 1 minute"
    treat_missing_data = "notBreaching"
    dimensions = {
        LoadBalancer = aws_lb.main.arn_suffix
    }
    alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
    name = "${local.name}-alerts"
    tags = { Name = "${local.name}-alerts" }
}