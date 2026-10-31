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

  

resource "aws_iam_user_policy_attachment" "lab_user_cloudwatch" { 

  user       = var.iam_user_name 

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess" 

} 

  

resource "time_sleep" "wait_for_iam_propagation" { 

  depends_on      = [aws_iam_user_policy_attachment.lab_user_cloudwatch] 

  create_duration = "10s" 

} 

  

resource "aws_cloudwatch_log_group" "checkout_service" { 

  name              = "/devsecops-lab/checkout-service" 

  retention_in_days = 3 

  depends_on        = [time_sleep.wait_for_iam_propagation] 

} 