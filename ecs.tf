data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "main" {
  count                   = var.create_secret ? 1 : 0
  name                    = "/ecs/fargate/${var.service}"
  recovery_window_in_days = 0
}

resource "aws_ecs_service" "main" {
  name                              = var.service
  cluster                           = var.cluster
  task_definition                   = var.volume == "" ? aws_ecs_task_definition.main[0].arn : aws_ecs_task_definition.main_volume[0].arn
  launch_type                       = "FARGATE"
  desired_count                     = var.container.count
  force_new_deployment              = true
  health_check_grace_period_seconds = var.container.health_check.grace_period
  propagate_tags                    = "SERVICE"

  network_configuration {
    security_groups = [aws_security_group.main.id]
    subnets         = var.network.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.service
    container_port   = var.network.port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_ecs_task_definition" "main_volume" {
  count                    = var.volume == "" ? 0 : 1
  family                   = var.service
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container.cpu
  memory                   = var.container.memory
  execution_role_arn       = aws_iam_role.main.arn
  task_role_arn            = aws_iam_role.main.arn
  container_definitions    = var.sidecar.image != "" ? "[${local.main_definition}, ${local.sidecar_definition}]" : "[${local.main_definition}]"
  skip_destroy             = true
  runtime_platform {
    operating_system_family = var.windows_deployment ? "WINDOWS_SERVER_2019_CORE" : "LINUX"
    cpu_architecture        = "X86_64"
  }
  volume {
    name = var.volume
  }
}

resource "aws_ecs_task_definition" "main" {
  count                    = var.volume == "" ? 1 : 0
  family                   = var.service
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container.cpu
  memory                   = var.container.memory
  execution_role_arn       = aws_iam_role.main.arn
  task_role_arn            = aws_iam_role.main.arn
  container_definitions    = var.sidecar.image != "" ? "[${local.main_definition}, ${local.sidecar_definition}]" : "[${local.main_definition}]"
  skip_destroy             = true
  runtime_platform {
    operating_system_family = var.windows_deployment ? "WINDOWS_SERVER_2019_CORE" : "LINUX"
    cpu_architecture        = "X86_64"
  }
}
