resource "kubernetes_namespace" "metallb_system" {
  metadata {
    name = "metallb-system"
    labels = {
        "pod-security.kubernetes.io/enforce" = "privileged"
        "pod-security.kubernetes.io/audit" = "privileged"
        "pod-security.kubernetes.io/warn" = "privileged"
    }
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace = kubernetes_namespace.metallb_system.id
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
}

resource "kubernetes_manifest" "metallb_ip_pool" {
  depends_on = [helm_release.metallb]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.metallb_system.id
    }
    spec = {
      addresses = [
        "192.168.0.220-192.168.0.250"
      ]
    }
  }
}

resource "kubernetes_manifest" "metallb_announcement" {
  depends_on = [helm_release.metallb]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.metallb_system.id
    }
  }
}
