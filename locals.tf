locals {

  sidecar_definition = templatefile(
    "${path.module}/container_definition.tpl",
    {
      service   = var.sidecar.name
      region    = data.aws_region.current.name
      image     = var.sidecar.image
      cpu       = var.sidecar.cpu
      memory    = var.sidecar.memory
      ports     = jsonencode([])
      log_group = var.log_group
      commands  = jsonencode([])

      environment  = jsonencode(var.sidecar.environment)
      mount_points = jsonencode(var.sidecar.mount_points)
    }
  )

  main_definition = templatefile(
    "${path.module}/container_definition.tpl",
    {
      service   = var.service
      region    = data.aws_region.current.name
      image     = var.container.image
      cpu       = var.sidecar.image != "" ? var.container.cpu - var.sidecar.cpu : var.container.cpu
      memory    = var.sidecar.image != "" ? var.container.memory - var.sidecar.memory : var.container.memory
      ports     = jsonencode([var.network.port])
      log_group = var.log_group
      commands  = jsonencode(var.container.commands)

      environment = jsonencode(concat(
        var.create_secret ? [{ name = "${upper(var.service)}_SECRET", value = aws_secretsmanager_secret.main[0].name }] : [],
        var.create_bucket ? [{ name = "${upper(var.service)}_S3_BUCKET", value = aws_s3_bucket.main[0].bucket }, { name = "${upper(var.service)}_S3_PREFIX", value = " " }] : [],
        var.container.environment
      ))
      mount_points = jsonencode(var.container.mount_points)
    }
  )
}