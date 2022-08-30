resource "aws_appautoscaling_policy" "cpu_policy" {
  count              = var.scaling.enabled ? 1 : 0
  name               = "${var.service}-cpu-policy"
  depends_on         = [aws_appautoscaling_target.scale_target[0]]
  service_namespace  = aws_appautoscaling_target.scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.scaling.cpu.threshold
    scale_in_cooldown  = var.scaling.scale_down.cpu.cooldown
    scale_out_cooldown = var.scaling.scale_up.cpu.cooldown
  }
}

resource "aws_appautoscaling_policy" "memory_policy" {
  count              = var.scaling.enabled ? 1 : 0
  name               = "${var.service}-memory-policy"
  depends_on         = [aws_appautoscaling_target.scale_target[0]]
  service_namespace  = aws_appautoscaling_target.scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.scaling.memory.threshold
    scale_in_cooldown  = var.scaling.scale_down.memory.cooldown
    scale_out_cooldown = var.scaling.scale_up.memory.cooldown
  }
}

resource "aws_appautoscaling_target" "scale_target" {
  count              = var.scaling.enabled ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster}/${var.service}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.scaling.scale_down.bound
  max_capacity       = var.scaling.scale_up.bound
}
