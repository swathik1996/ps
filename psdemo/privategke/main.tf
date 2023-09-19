terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.8.0"
    }
  }

  # Storing state file in remote 
  backend "gcs" {
   bucket = "gcp_psdemo_bucket"
   prefix = "terraform/state"
   credentials ="ps-demo-399516-3d986dac840b.json" 
  }
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  credentials = file("ps-demo-399516-3d986dac840b.json")
}

module "network" {
  source = "./modules/network"
  vpc = var.vpc
  subnet = var.subnet
  project     = var.project
  region      = var.region
  zone        = var.zone
  networkcidr = var.networkcidr
  tag = var.tag
}

module "k8s" {
  source = "./modules/k8s"
  vpc = var.vpc
  subnet = var.subnet
  project     = var.project
  region      = var.region
  zone        = var.zone
  clustername = var.clustername
  mastercidr = var.mastercidr
  clustercidr = var.clustercidr
  servicecidr = var.servicecidr
  authorizedcidr = var.authorizedcidr
  nodepoolmctype = var.nodepoolmctype
  tag = var.tag
  depends_on = [ module.network ]
}

module "nat" {
  source = "./modules/nat"
  vpc = var.vpc
  subnet = var.subnet
  project     = var.project
  region      = var.region
  zone        = var.zone
  natname = var.natname
  routername = var.routername
  tag = var.tag
  depends_on = [ module.network ]
}

module "vm" {
  source = "./modules/vm"
  vpc = var.vpc
  subnet = var.subnet
  project     = var.project
  region      = var.region
  zone        = var.zone
  tag = var.tag
  depends_on = [ module.network ]
}
