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

variable "control_plane_nodes" {
  description = "Map of control plane nodes"
  type = map(object({
    hostname = string
    endpoint = string
    ip       = string
  }))
}

variable "worker_nodes" {
  description = "Map of worker nodes"
  type = map(object({
    hostname = string
    endpoint = string
    ip       = string
  }))
}