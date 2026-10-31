output "api_url" { 

  value = aws_apigatewayv2_stage.default.invoke_url 

} 

  

output "queue_url" { 

  value = aws_sqs_queue.orders_api.id 

} 