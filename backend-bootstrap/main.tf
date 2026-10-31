terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
provider "aws" {
  region = "us-east-1"
}
 
resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.state_bucket_name
  force_destroy = true
}
 
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
 
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
 
  attribute {
    name = "LockID"
    type = "S"
  }
}
 
# Le otorga al usuario IAM del Laboratorio 3 el permiso que le falta
# para trabajar con DynamoDB, gestionado como código (no desde la consola).
resource "aws_iam_user_policy_attachment" "lab_user_dynamodb" {
  user       = var.iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
