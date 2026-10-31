terraform { 

  required_version = ">= 1.5.0" 

  required_providers { 

    aws = { 

      source  = "hashicorp/aws" 

      version = "~> 5.0" 

    } 

    time = { 

      source  = "hashicorp/time" 

      version = "~> 0.9" 

    } 

  } 

} 

 

provider "aws" { 

  region = "us-east-1" 

} 

 

resource "aws_iam_user_policy_attachment" "lab_user_eventbridge" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess" 

} 

 

resource "aws_iam_user_policy_attachment" "lab_user_sqs" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess" 

} 

 

resource "time_sleep" "wait_for_iam_propagation" { 

  depends_on = [ 

    aws_iam_user_policy_attachment.lab_user_eventbridge, 

    aws_iam_user_policy_attachment.lab_user_sqs, 

  ] 

  create_duration = "10s" 

} 

 

resource "aws_cloudwatch_event_bus" "orders" { 

  name       = "devsecops-lab-orders-bus" 

  depends_on = [time_sleep.wait_for_iam_propagation] 

} 

 

resource "aws_sqs_queue" "notifications" { 

  name       = "devsecops-lab-notifications-queue" 

  depends_on = [time_sleep.wait_for_iam_propagation] 

} 

 

resource "aws_sqs_queue" "inventory" { 

  name       = "devsecops-lab-inventory-queue" 

  depends_on = [time_sleep.wait_for_iam_propagation] 

} 

 

# Permite que EventBridge (no una persona, ni el usuario IAM) envíe mensajes a estas colas. 

# El aws:SourceArn debe ser el ARN de la REGLA, no el del bus. 

resource "aws_sqs_queue_policy" "notifications_policy" { 

  queue_url = aws_sqs_queue.notifications.id 

  policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [{ 

      Effect    = "Allow" 

      Principal = { Service = "events.amazonaws.com" } 

      Action    = "sqs:SendMessage" 

      Resource  = aws_sqs_queue.notifications.arn 

      Condition = { 

        ArnEquals = { "aws:SourceArn" = aws_cloudwatch_event_rule.order_created_notifications.arn } 

      } 

    }] 

  }) 

} 

 

resource "aws_sqs_queue_policy" "inventory_policy" { 

  queue_url = aws_sqs_queue.inventory.id 

  policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [{ 

      Effect    = "Allow" 

      Principal = { Service = "events.amazonaws.com" } 

      Action    = "sqs:SendMessage" 

      Resource  = aws_sqs_queue.inventory.arn 

      Condition = { 

        ArnEquals = { "aws:SourceArn" = aws_cloudwatch_event_rule.order_created_inventory.arn } 

      } 

    }] 

  }) 

} 

 

resource "aws_cloudwatch_event_rule" "order_created_notifications" { 

  name           = "devsecops-lab-order-created-to-notifications" 

  event_bus_name = aws_cloudwatch_event_bus.orders.name 

  event_pattern  = jsonencode({ "detail-type" = ["OrderCreated"] }) 

} 

 

resource "aws_cloudwatch_event_target" "notifications_target" { 

  rule           = aws_cloudwatch_event_rule.order_created_notifications.name 

  event_bus_name = aws_cloudwatch_event_bus.orders.name 

  arn            = aws_sqs_queue.notifications.arn 

} 

 

resource "aws_cloudwatch_event_rule" "order_created_inventory" { 

  name           = "devsecops-lab-order-created-to-inventory" 

  event_bus_name = aws_cloudwatch_event_bus.orders.name 

  event_pattern  = jsonencode({ "detail-type" = ["OrderCreated"] }) 

} 

 

resource "aws_cloudwatch_event_target" "inventory_target" { 

  rule           = aws_cloudwatch_event_rule.order_created_inventory.name 

  event_bus_name = aws_cloudwatch_event_bus.orders.name 

  arn            = aws_sqs_queue.inventory.arn 

} 