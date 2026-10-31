terraform { 

  required_version = ">= 1.5.0" 

  required_providers { 

    aws = { 

      source  = "hashicorp/aws" 

      version = "~> 5.0" 

    } 

  } 

} 

  

locals { 

  common_tags = merge( 

    { 

      Proyecto    = "DevSecOps-Lab" 

      Entorno     = var.environment 

      GestionadoPor = "Terraform" 

    }, 

    var.tags 

  ) 

} 

  

resource "aws_s3_bucket" "site" { 

  bucket = var.bucket_name 

  tags   = local.common_tags 

} 

  

resource "aws_s3_bucket_public_access_block" "site" { 

  bucket                  = aws_s3_bucket.site.id 

  block_public_acls       = false 

  block_public_policy     = false 

  ignore_public_acls      = false 

  restrict_public_buckets = false 

} 

  

resource "aws_s3_bucket_website_configuration" "site" { 

  bucket = aws_s3_bucket.site.id 

  index_document { 

    suffix = "index.html" 

  } 

} 

  

resource "aws_s3_bucket_policy" "public_read" { 

  bucket     = aws_s3_bucket.site.id 

  depends_on = [aws_s3_bucket_public_access_block.site] 

  policy = jsonencode({ 

    Version = "2012-10-17" 

    Statement = [{ 

      Sid       = "PublicReadGetObject" 

      Effect    = "Allow" 

      Principal = "*" 

      Action    = "s3:GetObject" 

      Resource  = "${aws_s3_bucket.site.arn}/*" 

    }] 

  }) 

} 

  

resource "aws_s3_object" "index" { 

  bucket       = aws_s3_bucket.site.id 

  key          = "index.html" 

  source       = var.index_file_path 

  content_type = "text/html" 

  etag         = filemd5(var.index_file_path) 

} 