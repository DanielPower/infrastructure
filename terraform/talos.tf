resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name        = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_machine_configuration" "control_plane" {
  cluster_name     = var.cluster_name
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each                    = var.control_plane_nodes
  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = each.value.endpoint
  config_patches              = [
    templatefile("./talos/templates/hostname.yaml", { hostname = each.value.hostname })
  ]
}

resource "talos_machine_configuration_apply" "workers" {
  for_each                    = var.worker_nodes
  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.endpoint
  config_patches              = [
    templatefile("./talos/templates/hostname.yaml", { hostname = each.value.hostname })
  ]
}