output "website_url" { 

  description = "URL pública del sitio desplegado" 

  value       = aws_s3_bucket_website_configuration.site.website_endpoint 

} 

  

output "bucket_arn" { 

  description = "ARN del bucket creado" 

  value       = aws_s3_bucket.site.arn 

} 