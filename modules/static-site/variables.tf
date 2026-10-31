variable "bucket_name" { 

  description = "Nombre único global del bucket S3" 

  type        = string 

} 

  

variable "index_file_path" { 

  description = "Ruta local al archivo index.html a publicar" 

  type        = string 

} 

  

variable "environment" { 

  description = "Nombre del ambiente (dev, staging, prod)" 

  type        = string 

  default     = "dev" 

} 

  

variable "tags" { 

  description = "Etiquetas adicionales para todos los recursos del módulo" 

  type        = map(string) 

  default     = {} 

} 