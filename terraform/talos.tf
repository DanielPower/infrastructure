locals {
  cluster_name     = "homelab"
  cluster_endpoint = "https://192.168.0.11:6443"
  talos_version    = "1.9.5"

  control_plane_nodes = {
    "linie" = {
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.11"
      ip       = "192.168.0.11"
    },
    "draht" = {
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.13"
      ip       = "192.168.0.13"
    },
    "lugner" = {
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.14"
      ip       = "192.168.0.14"
    }
  }
  worker_nodes = {
    "attlerock" = {
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.15"
      ip       = "192.168.0.15"
    }
    "timber-hearth" = {
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.16"
      ip       = "192.168.0.16"
    }
    "giants-deep" = {
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.17"
      ip       = "192.168.0.17"
    }
    "dark-bramble" = {
      disk     = "/dev/nvme0n1"
      endpoint = "192.168.0.18"
      ip       = "192.168.0.18"
    }
    "brittle-hollow" = {
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
  talos_version    = local.talos_version
  machine_type     = "worker"
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each                    = local.control_plane_nodes
  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = each.value.endpoint
  config_patches = [
    templatefile("./talos/templates/hostname.yaml", { hostname = each.key }),
    templatefile("./talos/templates/disk.yaml", {
      disk = each.value.disk,
    })
  ]
}

resource "talos_machine_configuration_apply" "workers" {
  for_each                    = local.worker_nodes
  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.endpoint
  config_patches = [
    templatefile("./talos/templates/hostname.yaml", { hostname = each.key }),
    templatefile("./talos/templates/disk.yaml", {
      disk = each.value.disk,
    })
  ]
}
