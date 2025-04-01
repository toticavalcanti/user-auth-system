resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name = "app-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }
  spec {
    # De acordo com o aviso, é melhor usar ingressClassName em vez da anotação
    ingress_class_name = "nginx"
    
    rule {
      http {
        # Frontend (rotas principais)
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "auth-ui-service"
              port {
                number = 80
              }
            }
          }
        }
        
        # API
        path {
          path = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = "auth-api-service"
              port {
                number = 3000
              }
            }
          }
        }
        
        # Rotas de autenticação
        path {
          path = "/register"
          path_type = "Prefix"
          backend {
            service {
              name = "auth-api-service"
              port {
                number = 3000
              }
            }
          }
        }
        
        path {
          path = "/login"
          path_type = "Prefix"
          backend {
            service {
              name = "auth-api-service"
              port {
                number = 3000
              }
            }
          }
        }
        
        path {
          path = "/forgot"
          path_type = "Prefix"
          backend {
            service {
              name = "auth-api-service"
              port {
                number = 3000
              }
            }
          }
        }
        
        path {
          path = "/user"
          path_type = "Prefix"
          backend {
            service {
              name = "auth-api-service"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    helm_release.ingress_nginx
  ]
}