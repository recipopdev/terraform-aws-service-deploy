locals {

  service_discovery_definition = templatefile(
    "${path.module}/container_definition.tpl", 
    {
      service   = var.service_discovery.name
      region    = data.aws_region.current.name
      image     = var.service_discovery.image
      cpu       = 128
      memory    = 256
      ports     = jsonencode([])
      log_group = var.log_group
      commands  = jsonencode([])

      environment = jsonencode([
        {
          name = "SERVICE_DISCOVERY_DIRECTORY",
          value = "/ecs"
        }
      ])
    }
  )

  main_definition = templatefile(
    "${path.module}/container_definition.tpl", 
    {
      service   = var.service
      region    = data.aws_region.current.name
      image     = var.container.image
      cpu       = var.container.cpu
      memory    = var.container.memory
      ports     = jsonencode([var.network.port])
      log_group = var.log_group
      commands  = jsonencode(var.container.commands)

      environment = jsonencode(concat(
        var.create_secret ? [{name="${upper(var.service)}_SECRET",value=aws_secretsmanager_secret.main[0].name}] : [],
        var.create_bucket ? [{name="${upper(var.service)}_S3_BUCKET",value=aws_s3_bucket.main[0].bucket}, {name="${upper(var.service)}_S3_PREFIX",value=" "}] : [],
        var.container.environment
      ))
    }
  )
}