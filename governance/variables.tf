variable "iam_user_name" { 

  type    = string 

  default = "lab-user" 

} 

  

variable "alert_email" { 

  description = "Correo que recibira el reporte diario de cumplimiento de etiquetas" 

  type        = string 

} 