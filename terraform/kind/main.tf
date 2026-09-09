terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_config_map" "relay_info" {
  metadata {
    name = "relay-info"
  }

  data = {
    product = "relay"
    module  = "4-terraform"
  }
}