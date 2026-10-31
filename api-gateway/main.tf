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

    archive = { 

      source  = "hashicorp/archive" 

      version = "~> 2.4" 

    } 

  } 

} 

 

provider "aws" { 

  region = "us-east-1" 

} 

 

resource "aws_iam_user_policy_attachment" "lab_user_lambda" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess" 

} 

 

resource "aws_iam_user_policy_attachment" "lab_user_apigateway" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator" 

} 

 

resource "aws_iam_user_policy_attachment" "lab_user_sqs" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess" 

} 

 

resource "time_sleep" "wait_for_iam_propagation" { 

  depends_on = [ 

    aws_iam_user_policy_attachment.lab_user_lambda, 

    aws_iam_user_policy_attachment.lab_user_apigateway, 

    aws_iam_user_policy_attachment.lab_user_sqs, 

  ] 

  create_duration = "10s" 

 

  # Si se agrega o cambia un permiso, la espera de 10s se repite 

  triggers = { 

    permisos = join(",", [ 

      aws_iam_user_policy_attachment.lab_user_lambda.id, 

      aws_iam_user_policy_attachment.lab_user_apigateway.id, 

      aws_iam_user_policy_attachment.lab_user_sqs.id, 

    ]) 

  } 

} 

 

resource "aws_sqs_queue" "orders_api" { 

  name       = "devsecops-lab-orders-api-queue" 

  depends_on = [time_sleep.wait_for_iam_propagation] 

} 

 

# Rol que asume CUALQUIER función Lambda de este laboratorio al ejecutarse 

# (distinto del usuario devsecops-lab-user: este rol lo usa AWS, no una persona). 

resource "aws_iam_role" "lambda_exec" { 

  name = "devsecops-lab-lambda-exec-role" 

  assume_role_policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [{ 

      Effect    = "Allow" 

      Principal = { Service = "lambda.amazonaws.com" } 

      Action    = "sts:AssumeRole" 

    }] 

  }) 

  depends_on = [time_sleep.wait_for_iam_propagation] 

} 

 

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" { 

  role       = aws_iam_role.lambda_exec.name 

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 

} 

 

resource "aws_iam_role_policy" "lambda_sqs_send" { 

  name = "devsecops-lab-lambda-sqs-send" 

  role = aws_iam_role.lambda_exec.id 

  policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [{ 

      Effect   = "Allow" 

      Action   = "sqs:SendMessage" 

      Resource = aws_sqs_queue.orders_api.arn 

    }] 

  }) 

} 

 

data "archive_file" "create_order_zip" { 

  type        = "zip" 

  source_file = "${path.module}/../lambda/create-order.js" 

  output_path = "${path.module}/create-order.zip" 

} 

 

resource "aws_lambda_function" "create_order" { 

  function_name    = "devsecops-lab-create-order" 

  role             = aws_iam_role.lambda_exec.arn 

  handler          = "create-order.handler" 

  runtime          = "nodejs20.x" 

  filename         = data.archive_file.create_order_zip.output_path 

  source_code_hash = data.archive_file.create_order_zip.output_base64sha256 

 

  environment { 

    variables = { 

      QUEUE_URL = aws_sqs_queue.orders_api.id 

    } 

  } 

} 

 

data "archive_file" "health_zip" { 

  type        = "zip" 

  source_file = "${path.module}/../lambda/health.js" 

  output_path = "${path.module}/health.zip" 

} 

 

resource "aws_lambda_function" "health" { 

  function_name    = "devsecops-lab-health" 

  role             = aws_iam_role.lambda_exec.arn 

  handler          = "health.handler" 

  runtime          = "nodejs20.x" 

  filename         = data.archive_file.health_zip.output_path 

  source_code_hash = data.archive_file.health_zip.output_base64sha256 

} 

 

resource "aws_apigatewayv2_api" "orders_api" { 

  name          = "devsecops-lab-orders-api" 

  protocol_type = "HTTP" 

  depends_on    = [time_sleep.wait_for_iam_propagation] 

} 

 

resource "aws_apigatewayv2_integration" "create_order_integration" { 

  api_id                 = aws_apigatewayv2_api.orders_api.id 

  integration_type       = "AWS_PROXY" 

  integration_uri        = aws_lambda_function.create_order.invoke_arn 

  payload_format_version = "2.0" 

} 

 

resource "aws_apigatewayv2_integration" "health_integration" { 

  api_id                 = aws_apigatewayv2_api.orders_api.id 

  integration_type       = "AWS_PROXY" 

  integration_uri        = aws_lambda_function.health.invoke_arn 

  payload_format_version = "2.0" 

} 

 

resource "aws_apigatewayv2_route" "post_orders" { 

  api_id    = aws_apigatewayv2_api.orders_api.id 

  route_key = "POST /orders" 

  target    = "integrations/${aws_apigatewayv2_integration.create_order_integration.id}" 

} 

 

resource "aws_apigatewayv2_route" "get_health" { 

  api_id    = aws_apigatewayv2_api.orders_api.id 

  route_key = "GET /health" 

  target    = "integrations/${aws_apigatewayv2_integration.health_integration.id}" 

} 

 

resource "aws_apigatewayv2_stage" "default" { 

  api_id      = aws_apigatewayv2_api.orders_api.id 

  name        = "$default" 

  auto_deploy = true 

} 

 

resource "aws_lambda_permission" "apigw_invoke_create_order" { 

  statement_id  = "AllowAPIGatewayInvokeCreateOrder" 

  action        = "lambda:InvokeFunction" 

  function_name = aws_lambda_function.create_order.function_name 

  principal     = "apigateway.amazonaws.com" 

  source_arn    = "${aws_apigatewayv2_api.orders_api.execution_arn}/*/*" 

} 

 

resource "aws_lambda_permission" "apigw_invoke_health" { 

  statement_id  = "AllowAPIGatewayInvokeHealth" 

  action        = "lambda:InvokeFunction" 

  function_name = aws_lambda_function.health.function_name 

  principal     = "apigateway.amazonaws.com" 

  source_arn    = "${aws_apigatewayv2_api.orders_api.execution_arn}/*/*" 

} 