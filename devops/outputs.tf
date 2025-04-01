# Frontend UI Service
output "auth_ui_service_name" {
  value       = kubernetes_service.auth_ui.metadata[0].name
  description = "The name of the Kubernetes service for the auth UI"
}

output "auth_ui_service_type" {
  value       = kubernetes_service.auth_ui.spec[0].type
  description = "The type of the Kubernetes service for the auth UI"
}

# Backend API Service
output "auth_api_service_name" {
  value       = kubernetes_service.auth_api.metadata[0].name
  description = "The name of the Kubernetes service for the auth API"
}

output "auth_api_service_type" {
  value       = kubernetes_service.auth_api.spec[0].type
  description = "The type of the Kubernetes service for the auth API"
}

output "auth_api_cluster_ip" {
  value       = kubernetes_service.auth_api.spec[0].cluster_ip
  description = "The Cluster IP of the auth API service"
}

# MySQL Service
output "mysql_service_name" {
  value       = kubernetes_service.mysql_service.metadata[0].name
  description = "The name of the Kubernetes service for MySQL"
}

output "mysql_connection_string" {
  value       = "mysql://root:${var.mysql_root_password}@tcp(${kubernetes_service.mysql_service.metadata[0].name}:3306)/mysql"
  sensitive   = true
  description = "MySQL connection string (sensitive)"
}

# Exibir IP/Host do Ingress
output "ingress_controller_ip_or_hostname" {
  value = try(
    kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].ip,
    try(
      kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].hostname,
      "Pending - External IP/Hostname not yet assigned"
    )
  )
  description = "O IP ou hostname atribuído ao Ingress pela DigitalOcean"
}

# URL final da aplicação via Ingress
output "application_url" {
  value = try(
    "http://${kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].ip}",
    try(
      "http://${kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].hostname}",
      "Pending - External IP/Hostname not yet assigned"
    )
  )
  description = "URL para acessar a aplicação (frontend) via Ingress"
}

# URL interna para a API
output "api_internal_url" {
  value = "http://${kubernetes_service.auth_api.metadata[0].name}:3000/api"
  description = "URL interna para a API"
}
