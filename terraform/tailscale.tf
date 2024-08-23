resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
    labels = {
        "pod-security.kubernetes.io/enforce" = "privileged"
        "pod-security.kubernetes.io/audit" = "privileged"
        "pod-security.kubernetes.io/warn" = "privileged"
    }
  }
}


resource "helm_release" "tailscale_operator" {
  name = "tailscale-operator"
  namespace = kubernetes_namespace.tailscale.id
  repository = "https://pkgs.tailscale.com/helmcharts"
  chart = "tailscale-operator"

  set {
    name  = "oauth.clientId"
    value = var.oauth_client_id
  }

  set {
    name  = "oauth.clientSecret"
    value = var.oauth_client_secret
  }
}

variable "oauth_client_id" {}
variable "oauth_client_secret" {}

