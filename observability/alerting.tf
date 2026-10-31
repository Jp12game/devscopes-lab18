resource "aws_iam_user_policy_attachment" "lab_user_sns" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess" 

} 

  

resource "time_sleep" "wait_for_sns_propagation" { 

  depends_on      = [aws_iam_user_policy_attachment.lab_user_sns] 

  create_duration = "10s" 

} 

  

resource "aws_sns_topic" "alerts" { 

  name       = "devsecops-lab-alerts" 

  depends_on = [time_sleep.wait_for_sns_propagation] 

} 

  

resource "aws_sns_topic_subscription" "email_alert" { 

  topic_arn = aws_sns_topic.alerts.arn 

  protocol  = "email" 

  endpoint  = var.alert_email 

} 