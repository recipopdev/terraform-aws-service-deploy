{
  "cpu": ${cpu},
  "image": "${image}",
  "memory": ${memory},
  "name": "${service}",
  "portMappings": ${jsonencode([
    for port in jsondecode(ports) : {
      containerPort = port,
      hostPort = port,
      protocol = "tcp"
    }
  ])},
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "${log_group}",
      "awslogs-region": "${region}",
      "awslogs-stream-prefix": "${service}"
    }
  },
  "environment": "${environment}",
  "command": "${commands}"
}