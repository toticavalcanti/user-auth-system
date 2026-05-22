variable "do_token" {
  type        = string
  sensitive   = true
  description = "Token de acesso para a API da DigitalOcean"
}

variable "do_region" {
  description = "Região onde o cluster será criado"
  type        = string
  default     = "nyc1"
}

variable "cluster_name" {
  description = "Nome do cluster Kubernetes"
  type        = string
  default     = "meu-cluster"
}

variable "cluster_version" {
  description = "Versão do Kubernetes (use: doctl kubernetes options versions)"
  type        = string
  default     = "1.35.1-do.6"
}

variable "namespace" {
  description = "Namespace Kubernetes para os recursos"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Ambiente de execução"
  type        = string
  default     = "production"
}

variable "backend_image" {
  description = "Imagem Docker do backend Go/Fiber"
  type        = string
  default     = "toticavalcanti/fiber-auth-api:v1.0"
}

variable "frontend_image" {
  description = "Imagem Docker do frontend React/Nginx"
  type        = string
  default     = "toticavalcanti/auth-ui:v1.1"
}

variable "mysql_image" {
  description = "Imagem Docker do MySQL"
  type        = string
  default     = "mysql:5.7"
}

variable "backend_replica_count" {
  description = "Número de réplicas do backend"
  type        = number
  default     = 1
}

variable "mysql_database" {
  description = "Nome do banco de dados MySQL"
  type        = string
  default     = "mysql"
}

variable "mysql_root_password" {
  description = "Senha do root para o MySQL"
  type        = string
  sensitive   = true
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

variable "react_app_api_url" {
  description = "URL para a API do auth-api"
  type        = string
  default     = "/api/"
}