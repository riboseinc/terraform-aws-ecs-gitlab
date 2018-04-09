# resource "aws_cloudwatch_metric_alarm" "memory_high" {
#   alarm_name          = "${var.prefix}-memory_high"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "3"
#   metric_name         = "MemoryReservation"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "80"
#   alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_up.arn}"]
# }
#
# resource "aws_cloudwatch_metric_alarm" "memory_low" {
#   alarm_name          = "${var.prefix}-memory_low"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = "3"
#   metric_name         = "MemoryReservation"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "80"
#   alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_down.arn}"]
# }

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.prefix}-cpu_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUReservation"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.prefix}-cpu_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUReservation"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "79"
  alarm_actions       = ["${aws_autoscaling_policy.ecs_instances_scale_down.arn}"]
}
