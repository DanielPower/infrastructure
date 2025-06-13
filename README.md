# Homelab Kubernetes Infrastructure

My bare-metal Kubernetes homelab cluster running on Talos Linux, managed with Tofu and GitOps using Flux.

## Cluster Overview

The cluster consists of a 7-node Kubernetes cluster running Talos Linux:

### Control Plane Nodes (3)
- **linie** - 192.168.0.11 (Primary endpoint)
- **draht** - 192.168.0.13
- **lugner** - 192.168.0.14

### Worker Nodes (5)
- **attlerock** - 192.168.0.15
- **timber-hearth** - 192.168.0.16
- **giants-deep** - 192.168.0.17
- **dark-bramble** - 192.168.0.18
- **brittle-hollow** - 192.168.0.19

*Workers are named after planets from The Outer Wilds.*

### Network Architecture

- **Cluster Network**: 192.168.0.x (reserved ranges on home network)
- **MetalLB Pool**: 192.168.0.220-250 (LoadBalancer services)
- **Ingress Controller**: 192.168.0.220 (NGINX)
- **Cluster Endpoint**: https://192.168.0.11:6443 _TODO: setup high availability endpoint_

## Infrastructure Components

### Core Infrastructure
- **Talos Linux** - Immutable Kubernetes OS
- **MetalLB** - Bare-metal load balancer
- **NGINX Ingress Controller** - HTTP/HTTPS ingress
- **cert-manager** - Automatic TLS certificate management
- **Tailscale** - VPN access with subnet routing
- **CloudNZ NFS CSI** - Network storage
- **CloudNativePG** - PostgreSQL operator
- **Prometheus** - Monitoring and observability

### Applications
The cluster hosts various applications including:
- **Media Services**: Jellyfin, Immich, Sonarr, Radarr, Prowlarr, qBittorrent
- **Web Applications**: Personal website, various custom applications
- **Discord Bots**: Balacord, Stock Corn, TwatBot
- **Utilities**: FlareSolverr, Thumbor image processing
- **Monitoring**: Prometheus with public proxy access

## Prerequisites

### Required Tools
- [Tofu](https://opentofu.org)
- [Flux CLI](https://fluxcd.io/flux/installation/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [SOPS](https://github.com/mozilla/sops)
- [age](https://github.com/FiloSottile/age)

## Setup Process

### 1. Talos Linux Installation

*TODO: Add instructions for provisioning Talos nodes using Tofu.*

### 2. Secret Management Setup

This project uses SOPS with age for secret encryption.

#### Generate age key pair:
```bash
age-keygen -o age.agekey
```

#### Set environment variable:
```bash
export SOPS_AGE_KEY_FILE=age.agekey
```

#### Update `.sops.yaml` with your public key:
```yaml
creation_rules:
  - path_regex: .*.yaml
    encrypted_regex: ^(data|stringData)$
    age: <your-age-public-key>
  - age: <your-age-public-key>
```

### 3. Tofu Cluster Provisioning

#### Initialize and apply Tofu:
```bash
cd terraform
tofu init
tofu plan
tofu apply
```

This will:
- Generate Talos machine configurations
- Apply configurations to all nodes
- Bootstrap the Kubernetes cluster

### 4. Flux Bootstrap

#### Create GitHub deploy key:
```bash
flux bootstrap github \
  --owner=danielpower \
  --repository=homelab \
  --branch=master \
  --path=flux \
  --personal
```

#### Create SOPS age secret:
```bash
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=age.agekey
```

### 5. Verify Deployment

#### Check Flux system:
```bash
kubectl get pods -n flux-system
flux get kustomizations
```

#### Monitor application rollout:
```bash
kubectl get pods --all-namespaces
flux get helmreleases --all-namespaces
```

## Directory Structure

```
infrastructure/
├── terraform/              # Tofu configurations
│   ├── talos.tf            # Talos cluster definition
│   ├── versions.tf         # Provider requirements
│   └── talos/templates/    # Machine configuration templates
├── flux/                   # Flux GitOps configurations
│   ├── flux-system/        # Flux bootstrap files
│   ├── infrastructure/     # Core infrastructure services
│   └── apps/              # Application deployments
├── .sops.yaml             # SOPS configuration
└── renovate.json          # Dependency updates
```

## DNS and TLS

### External Access
Services are exposed via NGINX ingress with automatic TLS certificates from Let's Encrypt:
- **Domain**: `*.danielpower.ca`
- **Certificate Issuer**: Let's Encrypt (HTTP-01 challenge)
- **Example**: https://photos.danielpower.ca (Immich)

### Internal Access
- **Tailscale**: Provides secure VPN access to cluster services
- **Subnet Router**: Exposes entire cluster network via Tailscale

## Maintenance

### Updating Applications
Applications are automatically updated via Renovate bot integration. Manual updates can be performed by modifying the respective Flux configurations.

### Talos Updates
_TODO: Document Talos update process_
Updates are not trivial through Tofu, because the machineconfig image is only used on initial install. https://github.com/siderolabs/terraform-provider-talos/issues/140
