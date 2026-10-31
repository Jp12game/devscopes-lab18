variable "iam_user_name" { 

  description = "Nombre del usuario IAM creado en el Laboratorio 3" 

  type        = string 

  default     = "lab-user" 

} 

variable "alert_email" { 

  description = "Correo que recibirá las alertas de CloudWatch" 

  type        = string 

} 