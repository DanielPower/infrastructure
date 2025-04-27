locals {
  cluster_name     = "homelab"
  cluster_endpoint = "https://192.168.0.11:6443"
  talos_version = "1.9.5"

  control_plane_nodes = {
    "linie" = {
      hostname = "controlplane-linie"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.11"
      ip       = "192.168.0.11"
    },
    "draht" = {
      hostname = "controlplane-draht"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.13"
      ip       = "192.168.0.13"
    },
    "lugner" = {
      hostname = "controlplane-lugner"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.14"
      ip       = "192.168.0.14"
    }
  }
  worker_nodes = {
    "heiter" = {
      hostname = "worker-heiter"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.10"
      ip       = "192.168.0.10"
    }
    "lawine" = {
      hostname = "worker-lawine"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.15"
      ip       = "192.168.0.15"
    }
    "kanne" = {
      hostname = "worker-kanne"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.16"
      ip       = "192.168.0.16"
    }
    "scharf" = {
      hostname = "worker-scharf"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.17"
      ip       = "192.168.0.17"
    }
    "ehre" = {
      hostname = "worker-ehre"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.18"
      ip       = "192.168.0.18"
    }
    "richter" = {
      hostname = "worker-richter"
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.19"
      ip       = "192.168.0.19"
    }
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_machine_configuration" "control_plane" {
  cluster_name     = local.cluster_name
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = local.cluster_endpoint
  talos_version    = local.talos_version
  machine_type     = "controlplane"
}

data "talos_machine_configuration" "worker" {
  cluster_name     = local.cluster_name
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = local.cluster_endpoint
  talos_version = local.talos_version
  machine_type     = "worker"
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each                    = local.control_plane_nodes
  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = each.value.endpoint
  config_patches = [
    templatefile("./talos/templates/hostname.yaml", { hostname = each.value.hostname }),
    templatefile("./talos/templates/disk.yaml", {
      disk  = each.value.disk,
    })
  ]
}

resource "talos_machine_configuration_apply" "workers" {
  for_each                    = local.worker_nodes
  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.endpoint
  config_patches = [
    templatefile("./talos/templates/hostname.yaml", { hostname = each.value.hostname }),
    templatefile("./talos/templates/disk.yaml", {
      disk  = each.value.disk,
    })
  ]
}
