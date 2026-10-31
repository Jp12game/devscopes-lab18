variable "state_bucket_name" {
  description = "Nombre único global del bucket que guardará el estado de Terraform"
  type        = string
}
 
variable "iam_user_name" {
  description = "Nombre del usuario IAM creado en el Laboratorio 3, al que se le agrega permiso de DynamoDB"
  type        = string
  default     = "devescopeslabpolanco"
}
