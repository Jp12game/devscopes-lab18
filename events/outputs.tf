output "event_bus_name" { 

  value = aws_cloudwatch_event_bus.orders.name 

} 

  

output "notifications_queue_url" { 

  value = aws_sqs_queue.notifications.id 

} 

  

output "inventory_queue_url" { 

  value = aws_sqs_queue.inventory.id 

} 