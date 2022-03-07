data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "main" {
  count                   = var.create_secret ? 1 : 0
  name                    = "/ecs/fargate/${var.service}"
  recovery_window_in_days = 0
}

resource "aws_ecs_service" "main" {
  name                 = var.service
  cluster              = var.cluster
  task_definition      = aws_ecs_task_definition.main.arn
  launch_type          = "FARGATE"
  desired_count        = var.container.count
  force_new_deployment = true

  network_configuration {
    security_groups = [aws_security_group.main.id]
    subnets         = var.network.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.service
    container_port   = var.network.port
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.service
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container.cpu
  memory                   = var.container.memory
  execution_role_arn       = aws_iam_role.main.arn
  task_role_arn            = aws_iam_role.main.arn
  container_definitions = jsonencode([
    {
      name      = var.service
      image     = var.container.image
      cpu       = var.container.cpu
      memory    = var.container.memory
      essential = true
      portMappings = [
        {
          containerPort = var.network.port
          hostPort      = var.network.port
        }
      ]
      environment = concat(
        var.create_secret ? [{name="${upper(var.service)}_SECRET",value=aws_secretsmanager_secret.main[0].name}] : [],
        var.create_bucket ? [{name="${upper(var.service)}_MODEL_S3_BUCKET",value=aws_s3_bucket.main[0].bucket}, {name="${upper(var.service)}_MODEL_S3_PREFIX",value=" "}] : [],
        var.container.environment
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.service
        }
      }
      command = var.container.commands
    }
  ])
}
