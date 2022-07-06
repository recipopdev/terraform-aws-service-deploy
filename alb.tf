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
      values = [var.loadbalancer.dns]
    }
  }
}
