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
  cpu                      = (var.container.cpu + (var.service_discovery ? 128 : 0))
  memory                   = (var.container.memory + (var.service_discovery ? 256 : 0))
  execution_role_arn       = aws_iam_role.main.arn
  task_role_arn            = aws_iam_role.main.arn
  container_definitions    = concat(
    var.service_discovery ? [data.template_file.service_discovery_container.rendered] : [],
    [data.template_file.main_container.rendered]
  )
  runtime_platform {
    operating_system_family = var.windows_deployment ? "WINDOWS_SERVER_2019_CORE" : "LINUX"
    cpu_architecture        = "X86_64"
  } 
}

data "template_file" "service_discovery_container" {
  template = file("${path.module}/container_definition.tpl")
  vars = {
    service   = var.service
    region    = data.aws_region.current.name
    image     = var.container.image
    cpu       = 128
    memory    = 256
    ports     = jsonencode([])
    log_group = var.log_group
    commands  = var.container.commands

    environment = [
      {
        name = "SERVICE_DISCOVERY_DIRECTORY",
        value = "/ecs"
      }
    ]
  }
}

data "template_file" "main_container" {
  template = file("${path.module}/container_definition.tpl")
  vars = {
    service   = var.service
    region    = data.aws_region.current.name
    image     = var.container.image
    cpu       = var.container.cpu
    memory    = var.container.memory
    port      = jsonencode([var.network.port])
    log_group = var.log_group
    commands  = var.container.commands

    environment = concat(
      var.create_secret ? [{name="${upper(var.service)}_SECRET",value=aws_secretsmanager_secret.main[0].name}] : [],
      var.create_bucket ? [{name="${upper(var.service)}_S3_BUCKET",value=aws_s3_bucket.main[0].bucket}, {name="${upper(var.service)}_S3_PREFIX",value=" "}] : [],
      var.container.environment
    )
  }
}
