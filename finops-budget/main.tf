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

resource "aws_iam_user_policy" "lab_user_budgets" {
  name = "devsecops-lab-budgets-access"
  user = var.iam_user_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "budgets:*"
      Resource = "*"
    }]
  })
}

resource "time_sleep" "wait_for_iam_propagation" {
  depends_on      = [aws_iam_user_policy.lab_user_budgets]
  create_duration = "10s"
}

resource "aws_budgets_budget" "monthly_cost" {
  name         = "devsecops-lab-monthly-budget"
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  depends_on = [time_sleep.wait_for_iam_propagation]
}
