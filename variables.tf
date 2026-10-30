variable "subscription_id" {
  type = string
}

variable "sufijo" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,8}$", var.sufijo))
    error_message = "Usa de 3 a 8 caracteres en minusculas y numeros."
  }
}

variable "location" {
  type    = string
  default = "brazilsouth"
}

variable "adf_location" {
  type    = string
  default = "eastus"
}

variable "sql_admin_login" {
  type    = string
  default = "sqladminucb"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "client_ip_start" {
  type    = string
  default = "0.0.0.0"
}

variable "client_ip_end" {
  type    = string
  default = "255.255.255.255"
}
