variable "iam_user_name" {
  description = "Usuario IAM del laboratorio, al que se le concede el permiso de Budgets"
  type        = string
  default     = "devsecops-lab-user"
}

variable "alert_email" {
  description = "Correo que recibira la alerta si el gasto supera el 80% del presupuesto"
  type        = string
}
