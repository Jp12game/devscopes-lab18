resource "aws_cloudwatch_metric_alarm" "high_error_rate" { 

  alarm_name          = "devsecops-lab-checkout-errors" 

  comparison_operator = "GreaterThanOrEqualToThreshold" 

  evaluation_periods  = 1 

  metric_name         = "ErrorCount" 

  namespace           = "DevSecOpsLab/CheckoutService" 

  period              = 300 

  statistic           = "Sum" 

  threshold           = 1 

  alarm_description   = "Se detectó al menos 1 error en el checkout en los últimos 5 minutos" 

  alarm_actions       = [aws_sns_topic.alerts.arn] 

  ok_actions          = [aws_sns_topic.alerts.arn] 

  treat_missing_data  = "notBreaching" 

} 

  

resource "aws_cloudwatch_metric_alarm" "high_latency" { 

  alarm_name          = "devsecops-lab-checkout-latency" 

  comparison_operator = "GreaterThanThreshold" 

  evaluation_periods  = 1 

  metric_name         = "LatencyMs" 

  namespace           = "DevSecOpsLab/CheckoutService" 

  period              = 300 

  statistic           = "Average" 

  threshold           = 500 

  alarm_description   = "La latencia promedio del checkout superó los 500 ms" 

  alarm_actions       = [aws_sns_topic.alerts.arn] 

  treat_missing_data  = "notBreaching" 

} 