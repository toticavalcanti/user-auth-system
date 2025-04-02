resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name = "app-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "8m"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        # Todas as rotas da API
        path {
          path      = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_api.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        path {
          path      = "/forgot"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_api.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        # Rota exata para POST /reset (processamento do formulário)
        path {
          path      = "/reset"
          path_type = "Exact"
          backend {
            service {
              name = kubernetes_service.auth_api.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        # Rota para /reset/[token] (visualização do formulário)
        path {
          path      = "/reset/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_ui.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path      = "/register"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_api.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        path {
          path      = "/login"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_api.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        path {
          path      = "/logout"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_api.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        path {
          path      = "/user"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_api.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }

        # Serve arquivos estáticos
        path {
          path      = "/static"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_ui.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        # Todas as outras rotas (como /reset/:token) vão para o frontend
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.auth_ui.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx]
}