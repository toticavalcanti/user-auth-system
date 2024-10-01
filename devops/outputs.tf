output "app_url" {
  value = kubernetes_service.auth_ui.status[0].load_balancer[0].ingress[0].ip
}

output "mysql_connection_string" {
  value = "mysql://root:$(MYSQL_ROOT_PASSWORD)@tcp(mysql-service:3306)/mysql"
}
