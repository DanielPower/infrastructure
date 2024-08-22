resource "helm_release" "tailscale_operator" {
  name = "tailscale-operator"
  namespace = "tailscale"
  create_namespace = true
  
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

