# ConfigMap para configurações do frontend
resource "kubernetes_config_map" "frontend_configs" {
  metadata {
    name = "frontend-configs"
  }

  data = {
    # Arquivo config.js com a variável window._env_
    "config.js" = "window._env_ = { REACT_APP_API_URL: \"/api\" };"
  }
}