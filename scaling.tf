resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.scaling.enabled ? 1 : 0
  alarm_name          = "${var.service}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scaling.scale_up.cpu.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling.scale_up.cpu.period
  statistic           = "Average"
  threshold           = var.scaling.scale_up.cpu.threshold
  dimensions = {
    ClusterName = var.cluster
    ServiceName = var.service
  }
  alarm_actions = [aws_appautoscaling_policy.cpu_scale_up_policy[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = var.scaling.enabled ? 1 : 0
  alarm_name          = "${var.service}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scaling.scale_down.cpu.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling.scale_down.cpu.period
  statistic           = "Average"
  threshold           = var.scaling.scale_down.cpu.threshold
  dimensions = {
    ClusterName = var.cluster
    ServiceName = var.service
  }
  alarm_actions = [aws_appautoscaling_policy.cpu_scale_down_policy[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.scaling.enabled ? 1 : 0
  alarm_name          = "${var.service}-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scaling.scale_up.memory.evaluation_period
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling.scale_up.memory.period
  statistic           = "Average"
  threshold           = var.scaling.scale_up.memory.threshold
  dimensions = {
    ClusterName = var.cluster
    ServiceName = var.service
  }
  alarm_actions = [aws_appautoscaling_policy.memory_scale_up_policy[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = var.scaling.enabled ? 1 : 0
  alarm_name          = "${var.service}-memory-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scaling.scale_down.memory.evaluation_period
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scaling.scale_down.memory.period
  statistic           = "Average"
  threshold           = var.scaling.scale_down.memory.threshold
  dimensions = {
    ClusterName = var.cluster
    ServiceName = var.service
  }
  alarm_actions = [aws_appautoscaling_policy.memory_scale_down_policy[0].arn]
}

resource "aws_appautoscaling_policy" "cpu_scale_up_policy" {
  count              = var.scaling.enabled ? 1 : 0
  name               = "${var.service}-cpu-scale-up-policy"
  depends_on         = [aws_appautoscaling_target.scale_target[0]]
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster}/${var.service}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scaling.scale_up.cpu.cooldown
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "cpu_scale_down_policy" {
  count              = var.scaling.enabled ? 1 : 0
  name               = "${var.service}-cpu-scale-down-policy"
  depends_on         = [aws_appautoscaling_target.scale_target[0]]
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster}/${var.service}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scaling.scale_down.cpu.cooldown
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_policy" "memory_scale_up_policy" {
  count              = var.scaling.enabled ? 1 : 0
  name               = "${var.service}-memory-scale-up-policy"
  depends_on         = [aws_appautoscaling_target.scale_target[0]]
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster}/${var.service}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scaling.scale_up.memory.cooldown
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "memory_scale_down_policy" {
  count              = var.scaling.enabled ? 1 : 0
  name               = "${var.service}-memory-scale-down-policy"
  depends_on         = [aws_appautoscaling_target.scale_target[0]]
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster}/${var.service}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scaling.scale_down.memory.cooldown
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
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
