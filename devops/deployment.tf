# # Backend Deployment
# resource "kubernetes_deployment" "auth_api" {
#   metadata {
#     name = "auth-api"
#   }
#   spec {
#     replicas = 1
#     selector {
#       match_labels = {
#         app = "auth-api"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "auth-api"
#         }
#       }
#       spec {
#         container {
#           name  = "auth-api"
#           image = "toticavalcanti/fiber-auth-api:v1.0"

#           # Variável de ambiente do MySQL
#           env {
#             name  = "MYSQL_ROOT_PASSWORD"
#             value_from {
#               secret_key_ref {
#                 name = "mysql-secret"
#                 key  = "mysql-root-password"
#               }
#             }
#           }

#           # Variável de ambiente DB_DSN
#           env {
#             name  = "DB_DSN"
#             value = "root:$(MYSQL_ROOT_PASSWORD)@tcp(mysql-service:3306)/mysql"
#           }

#           # Porta onde o backend escuta
#           port {
#             container_port = 3000
#           }

#           # Configuração de recursos
#           resources {
#             limits = {
#               cpu    = "250m"
#               memory = "256Mi"
#             }
#             requests = {
#               cpu    = "100m"
#               memory = "128Mi"
#             }
#           }
#         }
#       }
#     }
#   }
# }

# # Serviço do backend (ClusterIP)
# resource "kubernetes_service" "auth_api" {
#   metadata {
#     name = "auth-api-service"
#   }
#   spec {
#     selector = {
#       app = "auth-api"
#     }
#     type = "ClusterIP"
#     port {
#       port        = 3000
#       target_port = 3000
#     }
#   }
# }

# # Frontend Deployment
# resource "kubernetes_deployment" "auth_ui" {
#   metadata {
#     name = "auth-ui"
#   }
#   spec {
#     replicas = 1
#     selector {
#       match_labels = {
#         app = "auth-ui"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "auth-ui"
#         }
#       }
#       spec {
#         container {
#           name  = "auth-ui"
#           image = "toticavalcanti/auth-ui:v1.0"

#           # Variável de ambiente para o frontend se comunicar com o backend
#           env {
#             name  = "REACT_APP_API_URL"
#             value = "/api"
#           }

#           # Porta onde o frontend escuta
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
# }

# # Serviço do Frontend (ClusterIP)
# resource "kubernetes_service" "auth_ui" {
#   metadata {
#     name = "auth-ui-service"
#   }
#   spec {
#     selector = {
#       app = "auth-ui"
#     }
#     type = "ClusterIP"
#     port {
#       port        = 80
#       target_port = 80
#     }
#   }
# }

# # Serviço do MySQL (ClusterIP, com IP fixo no cluster)
# resource "kubernetes_service" "mysql_service" {
#   metadata {
#     name = "mysql-service"
#   }
#   spec {
#     selector = {
#       app = "mysql"
#     }
#     port {
#       port        = 3306
#       target_port = 3306
#     }
#     cluster_ip = "None"
#   }
# }

# # Persistent Volume
# resource "kubernetes_persistent_volume" "mysql_pv" {
#   metadata {
#     name = "mysql-pv"
#   }
#   spec {
#     capacity = {
#       storage = "1Gi"
#     }
#     access_modes = ["ReadWriteOnce"]
#     persistent_volume_reclaim_policy = "Retain"
#     storage_class_name = "manual"
#     host_path {
#       path = "/mnt/data"
#     }
#   }
# }

# # Persistent Volume Claim
# resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
#   metadata {
#     name = "mysql-pvc"
#   }
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "1Gi"
#       }
#     }
#     storage_class_name = "manual"
#   }
# }

# # MySQL Pod
# resource "kubernetes_pod" "mysql_pod" {
#   metadata {
#     name = "mysql-pod"
#     labels = {
#       app = "mysql"
#     }
#   }
#   spec {
#     containers {
#       name  = "mysql"
#       image = "mysql:5.7"
#       env {
#         name = "MYSQL_ROOT_PASSWORD"
#         value_from {
#           secret_key_ref {
#             name = "mysql-secret"
#             key  = "mysql-root-password"
#           }
#         }
#       }
#       volume_mounts {
#         mount_path = "/var/lib/mysql"
#         name       = "mysql-storage"
#       }
#     }
#     volumes {
#       name = "mysql-storage"
#       persistent_volume_claim {
#         claim_name = "mysql-pvc"
#       }
#     }
#   }
# }

# # Ingress Resource
# resource "kubernetes_ingress_v1" "auth_ingress" {
#   metadata {
#     name = "auth-ingress"
#     annotations = {
#       "kubernetes.io/ingress.class" = "nginx"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
#     }
#   }
#   spec {
#     rule {
#       http {
#         path {
#           path = "/()(.*)$"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = kubernetes_service.auth_ui.metadata[0].name
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#         path {
#           path = "/api(/|$)(.*)"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = kubernetes_service.auth_api.metadata[0].name
#               port {
#                 number = 3000
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

# # Secret for MySQL
# resource "kubernetes_secret" "mysql_secret" {
#   metadata {
#     name = "mysql-secret"
#   }
#   data = {
#     mysql-root-password = base64encode("yourpassword")
#   }
# }
