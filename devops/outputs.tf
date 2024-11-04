# Frontend UI Service
output "auth_ui_service_name" {
  value       = kubernetes_service.auth_ui.metadata[0].name
  description = "The name of the Kubernetes service for the auth UI"
}

output "auth_ui_service_type" {
  value       = kubernetes_service.auth_ui.spec[0].type
  description = "The type of the Kubernetes service for the auth UI"
}

output "auth_ui_load_balancer_ip" {
  value       = try(kubernetes_service.auth_ui.status[0].load_balancer[0].ingress[0].ip, "Pending")
  description = "The external IP of the load balancer for the auth UI service (if available)"
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

# Application URL (external access to frontend)
output "application_url" {
  value = try(
    "http://${kubernetes_service.auth_ui.status[0].load_balancer[0].ingress[0].ip}",
    "Pending - External IP not yet assigned"
  )
  description = "The URL to access the application (if available)"
}

# API URL for frontend (internal communication)
output "api_internal_url" {
  value = "http://${kubernetes_service.auth_api.metadata[0].name}:3000/api"
  description = "The internal URL for the backend API service for use within the cluster"
}
