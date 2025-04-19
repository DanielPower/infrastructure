variable "talos_config_path" {
  description = "Path to the Talos configuration file"
  type        = string
  default     = "../talos/talosconfig"
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "homelab"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint"
  type        = string
  default     = "https://192.168.0.10:6443"
}

variable "talos_version" {
  description = "Talos version"
  type        = string
  default     = "v1.9.4"
}

variable "talos_machine_secrets" {
  description = "Talos machine secrets"
  type        = object({
    id = string
    machine_secrets = object({
      certs = string
      cluster = string
      secrets = string
      trustdinfo = string
    })
    client_configuration = object({
      ca_certificate = string
      client_certificate = string
      client_key = string
    })
  })
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.30.1"
}

variable "control_plane_nodes" {
  description = "Map of control plane nodes"
  type = map(object({
    hostname = string
    endpoint = string
    ip       = string
    disk     = optional(string)
  }))
}

variable "worker_nodes" {
  description = "Map of worker nodes"
  type = map(object({
    hostname = string
    endpoint = string
    ip       = string
    disk     = optional(string)
  }))
}