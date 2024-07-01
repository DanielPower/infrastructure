resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "helm_release" "nginx-ingress" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.nginx.id
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  set {
    name = "controller.service.annotations.metallb\\.universe\\.tf/loadBalancerIPs"
    value = "192.168.0.220"
  }
}
