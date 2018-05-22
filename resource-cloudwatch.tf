resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.prefix}-memory_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "mem_used_percent"
  namespace           = "Custom/EC2"
  period              = "180"
  statistic           = "Minimum"
  threshold           = "60"
  alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_up.arn}"]
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = "${var.prefix}-memory_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "mem_used_percent"
  namespace           = "Custom/Custom/EC2"
  period              = "180"
  statistic           = "Maximum"
  threshold           = "60"
  alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_down.arn}"]
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.prefix}-cpu_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "180"
  statistic           = "Minimum"
  threshold           = "80"
  alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.prefix}-cpu_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "180"
  statistic           = "Maximum"
  threshold           = "80"
  alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_down.arn}"]
}
