{
  name         = ${service}
  image        = ${image}
  cpu          = ${cpu}
  memory       = ${memory}
  essential    = true
  portMappings = ${jsonencode([
    for port in jsondecode(ports) : {
      containerPort = port,
      hostPort = port,
      protocol = "tcp"
    }
  ])}
  environment = ${environment}

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = ${log_group}
      awslogs-region        = ${region}
      awslogs-stream-prefix = ${service}
    }
  }
  command = ${commands}
}