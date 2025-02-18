resource "aws_lb_target_group" "main" {
  name        = "${var.service}-http"
  port        = var.network.port
  protocol    = "HTTP"
  vpc_id      = var.network.vpc
  target_type = "ip"

  health_check {
    port    = var.network.port
    path    = var.container.health_check.path
    matcher = var.container.health_check.status_code
    timeout = var.container.health_check.timeout
  }

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.loadbalancer.listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = var.loadbalancer.dns
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
  # only want alarm on prod, dev/uat scales down at night
  count               = local.environment == "prod" && var.monitoring.enabled == true ? 1 : 0
  alarm_name          = "${var.service}-HealthyHostCount"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Minimum"
  period              = 60
  threshold           = 1
  alarm_description   = "Triggers when ${var.service} target group has no healthy hosts."
  alarm_actions       = [var.monitoring.alarm]

  dimensions = {
    TargetGroup = aws_lb_target_group.main.arn_suffix
    # needs to be ARN suffix
    LoadBalancer = regex("loadbalancer/(.*)", var.loadbalancer.id)
  }
}
