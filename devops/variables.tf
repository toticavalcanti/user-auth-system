variable "do_token" {
  type        = string
  sensitive   = true
  description = "Token de acesso para a API da DigitalOcean"
}

variable "gmail_username" {
  type        = string
  description = "Endereço do Gmail para enviar emails"
}

variable "gmail_password" {
  type        = string
  sensitive   = true
  description = "Senha do Gmail ou Senha de App"
}

variable "mysql_root_password" {
  description = "Senha do root para o MySQL"
  type        = string
}