variable "app_url" {
  description = "URL da aplicação"
  type        = string
}

variable "db_dsn" {
  description = "String de conexão DSN para o banco de dados"
  type        = string
}

variable "do_token" {
  description = "Token de acesso para a API da DigitalOcean"
  type        = string
}

variable "gmail_username" {
  description = "Endereço do Gmail para enviar emails"
  type        = string
}

variable "gmail_password" {
  description = "Senha do Gmail ou Senha de App"
  type        = string
}
