output "app_url" {
  value = kubernetes_service.auth_ui.status[0].load_balancer[0].ingress[0].ip
}

output "mysql_connection_string" {
  value = "mysql://${digitalocean_database_cluster.my_mysql_db.user}:${digitalocean_database_cluster.my_mysql_db.password}@${digitalocean_database_cluster.my_mysql_db.host}:${digitalocean_database_cluster.my_mysql_db.port}/${digitalocean_database_cluster.my_mysql_db.database}"
  sensitive = true
}