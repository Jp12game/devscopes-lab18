resource "aws_iam_user_policy_attachment" "lab_user_dynamodb_cqrs" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess" 

} 

  

resource "time_sleep" "wait_for_dynamodb_propagation" { 

  depends_on      = [aws_iam_user_policy_attachment.lab_user_dynamodb_cqrs] 

  create_duration = "10s" 

} 

  

resource "aws_dynamodb_table" "orders_read_model" { 

  name         = "devsecops-lab-orders-read-model" 

  billing_mode = "PAY_PER_REQUEST" 

  hash_key     = "orderId" 

  

  attribute { 

    name = "orderId" 

    type = "S" 

  } 

  

  depends_on = [time_sleep.wait_for_dynamodb_propagation] 

} 