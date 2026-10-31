resource "aws_iam_user_policy_attachment" "lab_user_sns_fanout" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess" 

} 

  

resource "time_sleep" "wait_for_sns_propagation" { 

  depends_on      = [aws_iam_user_policy_attachment.lab_user_sns_fanout] 

  create_duration = "10s" 

} 

  

resource "aws_sns_topic" "order_events" { 

  name       = "devsecops-lab-order-events-topic" 

  depends_on = [time_sleep.wait_for_sns_propagation] 

} 

  

resource "aws_sqs_queue" "billing" { 

  name = "devsecops-lab-billing-queue" 

} 

  

resource "aws_sqs_queue" "shipping" { 

  name = "devsecops-lab-shipping-queue" 

} 

  

resource "aws_sqs_queue_policy" "billing_policy" { 

  queue_url = aws_sqs_queue.billing.id 

  policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [{ 

      Effect    = "Allow" 

      Principal = { Service = "sns.amazonaws.com" } 

      Action    = "sqs:SendMessage" 

      Resource  = aws_sqs_queue.billing.arn 

      Condition = { ArnEquals = { "aws:SourceArn" = aws_sns_topic.order_events.arn } } 

    }] 

  }) 

} 

  

resource "aws_sqs_queue_policy" "shipping_policy" { 

  queue_url = aws_sqs_queue.shipping.id 

  policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [{ 

      Effect    = "Allow" 

      Principal = { Service = "sns.amazonaws.com" } 

      Action    = "sqs:SendMessage" 

      Resource  = aws_sqs_queue.shipping.arn 

      Condition = { ArnEquals = { "aws:SourceArn" = aws_sns_topic.order_events.arn } } 

    }] 

  }) 

} 

  

resource "aws_sns_topic_subscription" "billing_sub" { 

  topic_arn = aws_sns_topic.order_events.arn 

  protocol  = "sqs" 

  endpoint  = aws_sqs_queue.billing.arn 

} 

  

resource "aws_sns_topic_subscription" "shipping_sub" { 

  topic_arn = aws_sns_topic.order_events.arn 

  protocol  = "sqs" 

  endpoint  = aws_sqs_queue.shipping.arn 

} 

  

output "order_events_topic_arn" { 

  value = aws_sns_topic.order_events.arn 

} 