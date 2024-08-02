resource "helm_release" "csi_nfs" {
  name      = "csi-driver-nfs"
  namespace = "kube-system"

  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  version    = "v4.7.0"
}

resource "kubernetes_storage_class" "nfs" {
  metadata {
    name = "nfs-csi"
  }

  storage_provisioner = "nfs.csi.k8s.io"

  parameters = {
    server = "192.168.0.2"
    share  = "/main"
    subDir = "crispykube/$${pvc.metadata.namespace}/$${pvc.metadata.name}"
    onDelete = "archive"
  }
}

resource "kubernetes_storage_class" "nfs_root" {
  metadata {
    name = "nfs-csi-root"
  }

  storage_provisioner = "nfs.csi.k8s.io"

  parameters = {
    server = "192.168.0.2"
    share  = "/main"
    subDir = "$${pvc.metadata.path}"
    onDelete = "retain"
  }
}
