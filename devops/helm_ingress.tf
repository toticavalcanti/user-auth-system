resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "default"
  timeout    = 600

  # Precisamos do Service tipo LoadBalancer
  # para a DigitalOcean provisionar IP externo
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  # Publicar service do controller para relatarmos IP
  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}
