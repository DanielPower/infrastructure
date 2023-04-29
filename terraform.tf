terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "web" {
  image     = "fedora-37-x64"
  name      = "personal-site"
  region    = "tor1"
  size      = "s-1vcpu-1gb"
  user_data = file("${path.module}/cloud-config.yaml")
}

resource "digitalocean_domain" "domain" {
  name = "danielpower.ca"
}

resource "digitalocean_record" "main" {
  domain = digitalocean_domain.domain.name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.web.ipv4_address
}

resource "digitalocean_record" "email_cname" {
  domain = digitalocean_domain.domain.name
  type   = "CNAME"
  name   = "mail"
  value  = "mail.hover.com.cust.hostedemail.com."
}

resource "digitalocean_record" "email_mx" {
  domain   = digitalocean_domain.domain.name
  type     = "MX"
  name     = "@"
  value    = "mx.hover.com.cust.hostedemail.com."
  priority = 10
}
