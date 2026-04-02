resource "aws_lb" "main" {
    name = "${local.name}-alb"
    internal = false
    load_balancer_type = "application"
    subnets = aws_subnet.public[*].id
    tags = { Name = "${local.name}-alb"}
}

resource "aws_lb_target_group" "blue" {
    name = "${local.name}-tg-blue"
    port = var.container_port
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip"

    health_check {
        path = "/health"
        protocol = "HTTP"
        healthy_threshold = 2
        unhealthy_threshold = 3
        timeout = 5
        interval = 30
        matcher = "200"
    }

    deregistration_delay = 60
    tags = { Name = "${local.name}-tg-blue"}
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_lb_target_group" "green" {
    name = "${local.name}-tg-green"
    port = var.container_port
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip"

    health_check {
        path = "/health"
        protocol = "HTTP"
        healthy_threshold = 2
        unhealthy_threshold = 3
        timeout = 5
        interval = 30
        matcher = "200"
    }

    deregistration_delay = 60
    tags = { Name = "${local.name}-tg-green"}
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_lb_listener" "prod" {
    load_balancer_arn = aws_lb.main.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.blue.arn
    }

    lifecycle {
      ignore_changes = [default_action]
    }
}

resource "aws_lb_listener" "test" {
    load_balancer_arn = aws_lb.main.arn
    port = 8080
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.green.arn
    }

    lifecycle {
      ignore_changes = [default_action]
    }
}

