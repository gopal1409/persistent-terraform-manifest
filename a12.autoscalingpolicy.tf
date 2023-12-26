####based on cpu utilization
resource "aws_autoscaling_policy" "average_cpu_policy_greater_then_xx" {
  name = "average-cpu-policy-greater-then-xx"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.id 
  estimated_instance_warmup = 180 

  ##cpu utilization is above 90
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

##based on alb target utilziation. 
resource "aws_autoscaling_policy" "alb_target_requests_greater_than_yy" {
  name = "alb-target-requestgreater-then-yy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.id 
  estimated_instance_warmup = 120

  ##cpu utilization is above 90
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_alb.alb.arn_suffix}/${aws_alb_target_group.target_group.arn_suffix}"
    }
    target_value = 10.0
  }
}
