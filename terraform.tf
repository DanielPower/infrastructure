terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "ssh_key" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "main" {
  image     = "fedora-38-x64"
  name      = "personal-site"
  region    = "tor1"
  size      = "s-1vcpu-1gb"
  user_data = file("${path.module}/cloud-config.yaml")
  ssh_keys  = [digitalocean_ssh_key.main.fingerprint]
}

resource "digitalocean_volume" "main" {
  region                  = "tor1"
  name                    = "main-persistence"
  size                    = 5
  initial_filesystem_type = "xfs"
}

resource "digitalocean_volume_attachment" "main" {
  droplet_id = digitalocean_droplet.main.id
  volume_id  = digitalocean_volume.main.id
}

resource "digitalocean_reserved_ip" "reserved_ip" {
  droplet_id = digitalocean_droplet.main.id
  region     = digitalocean_droplet.main.region
}

resource "digitalocean_ssh_key" "main" {
  name       = "personal-site"
  public_key = var.ssh_key
}

resource "digitalocean_domain" "danielpower" {
  name = "danielpower.ca"
}

resource "digitalocean_record" "danielpower" {
  domain = digitalocean_domain.danielpower.name
  type   = "A"
  name   = "@"
  value  = digitalocean_reserved_ip.reserved_ip.ip_address
}

resource "digitalocean_record" "danielpower_subdomains" {
  domain = digitalocean_domain.danielpower.name
  type   = "A"
  name   = "*"
  value  = digitalocean_reserved_ip.reserved_ip.ip_address
}

resource "digitalocean_record" "danielpower_email_cname" {
  domain = digitalocean_domain.danielpower.name
  type   = "CNAME"
  name   = "mail"
  value  = "mail.hover.com.cust.hostedemail.com."
}

resource "digitalocean_record" "danielpower_email_mx" {
  domain   = digitalocean_domain.danielpower.name
  type     = "MX"
  name     = "@"
  value    = "mx.hover.com.cust.hostedemail.com."
  priority = 10
}

resource "digitalocean_domain" "danpower" {
  name = "danpower.ca"
}

resource "digitalocean_record" "danpower" {
  domain = digitalocean_domain.danpower.name
  type   = "A"
  name   = "@"
  value  = digitalocean_reserved_ip.reserved_ip.ip_address
}

resource "digitalocean_record" "danpower_subdomains" {
  domain = digitalocean_domain.danpower.name
  type   = "A"
  name   = "*"
  value  = digitalocean_reserved_ip.reserved_ip.ip_address
}

resource "digitalocean_domain" "gulch_nexus" {
  name = "gulch.nexus"
}

resource "digitalocean_record" "gulch_nexus" {
  domain = digitalocean_domain.gulch_nexus.name
  type   = "A"
  name   = "@"
  value  = digitalocean_reserved_ip.reserved_ip.ip_address
}

resource "digitalocean_record" "gulch_nexus_subdomains" {
  domain = digitalocean_domain.gulch_nexus.name
  type   = "A"
  name   = "*"
  value  = digitalocean_reserved_ip.reserved_ip.ip_address
}
