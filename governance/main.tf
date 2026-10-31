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

 

resource "aws_iam_user_policy_attachment" "lab_user_sns" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess" 

} 

 

resource "aws_iam_user_policy_attachment" "lab_user_eventbridge" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess" 

} 

 

resource "time_sleep" "wait_for_iam_propagation" { 

  depends_on = [ 

    aws_iam_user_policy_attachment.lab_user_lambda, 

    aws_iam_user_policy_attachment.lab_user_sns, 

    aws_iam_user_policy_attachment.lab_user_eventbridge, 

  ] 

  create_duration = "10s" 

 

  triggers = { 

    permisos = join(",", [ 

      aws_iam_user_policy_attachment.lab_user_lambda.id, 

      aws_iam_user_policy_attachment.lab_user_sns.id, 

      aws_iam_user_policy_attachment.lab_user_eventbridge.id, 

    ]) 

  } 

} 

 

resource "aws_sns_topic" "cost_governance_alerts" { 

  name       = "devsecops-lab-cost-governance-alerts" 

  depends_on = [time_sleep.wait_for_iam_propagation] 

} 

 

resource "aws_sns_topic_subscription" "email_alert" { 

  topic_arn = aws_sns_topic.cost_governance_alerts.arn 

  protocol  = "email" 

  endpoint  = var.alert_email 

} 

 

resource "aws_iam_role" "lambda_exec" { 

  name = "devsecops-lab-tag-checker-role" 

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

 

resource "aws_iam_role_policy" "lambda_permissions" { 

  name = "devsecops-lab-tag-checker-permissions" 

  role = aws_iam_role.lambda_exec.id 

  policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [ 

      { 

        Effect   = "Allow" 

        Action   = ["s3:ListAllMyBuckets", "s3:GetBucketTagging"] 

        Resource = "*" 

      }, 

      { 

        Effect   = "Allow" 

        Action   = "sns:Publish" 

        Resource = aws_sns_topic.cost_governance_alerts.arn 

      } 

    ] 

  }) 

} 

 

data "archive_file" "tag_checker_zip" { 

  type        = "zip" 

  source_file = "${path.module}/../lambda-governance/tag-compliance-checker.js" 

  output_path = "${path.module}/tag-compliance-checker.zip" 

} 

 

resource "aws_lambda_function" "tag_checker" { 

  function_name    = "devsecops-lab-tag-compliance-checker" 

  role             = aws_iam_role.lambda_exec.arn 

  handler          = "tag-compliance-checker.handler" 

  runtime          = "nodejs20.x" 

  timeout          = 30 

  filename         = data.archive_file.tag_checker_zip.output_path 

  source_code_hash = data.archive_file.tag_checker_zip.output_base64sha256 

 

  environment { 

    variables = { 

      TOPIC_ARN = aws_sns_topic.cost_governance_alerts.arn 

    } 

  } 

} 

 

resource "aws_cloudwatch_event_rule" "daily_check" { 

  name                = "devsecops-lab-daily-tag-check" 

  schedule_expression = "rate(1 day)" 

  depends_on          = [time_sleep.wait_for_iam_propagation] 

} 

 

resource "aws_cloudwatch_event_target" "invoke_lambda" { 

  rule = aws_cloudwatch_event_rule.daily_check.name 

  arn  = aws_lambda_function.tag_checker.arn 

} 

 

resource "aws_lambda_permission" "allow_eventbridge" { 

  statement_id  = "AllowEventBridgeInvoke" 

  action        = "lambda:InvokeFunction" 

  function_name = aws_lambda_function.tag_checker.function_name 

  principal     = "events.amazonaws.com" 

  source_arn    = aws_cloudwatch_event_rule.daily_check.arn 

} 