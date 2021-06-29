// Create the Google Cloud Networking
module "vpc1_networking" {
  // Module Source
  source                = "git::https://github.com/danmanners/GCP-Learning.git//Single-Node-Multi-Provider/modules/google_cloud/vpc"

  // Google Project Information
  google_project_id     = var.google_cloud_auth.google_project_id
  google_project_region = var.google_cloud_auth.google_project_region

  // Networking Settings
  vpc_name              = var.gcloud_vpc1.vpc_name
  vpc_public_subnets    = var.gcloud_vpc1.vpc_public_subnets
}

// Create the Google Cloud Firewall
module "vpc1_fw_ingress" {
  // Module Source
  source                = "git::https://github.com/danmanners/GCP-Learning.git//Single-Node-Multi-Provider/modules/google_cloud/firewall"

  // Google Project Information
  google_project_id     = var.google_cloud_auth.google_project_id
  google_project_region = var.google_cloud_auth.google_project_region

  // Firewall Settings
  name = var.gcloud_vpc1.ingress_rules.name
  network = module.vpc1_networking.vpc_name
  direction = var.gcloud_vpc1.ingress_rules.direction
  target_tags = var.gcloud_vpc1.ingress_rules.target_tags

  // Allow Blocks
  allow_blocks = var.gcloud_vpc1.ingress_rules.allow_blocks
}

// Create the Google Cloud compute instances
module "vpc1_compute" {
  // Module Source
  source                = "git::https://github.com/danmanners/GCP-Learning.git//Single-Node-Multi-Provider/modules/google_cloud/compute"

  // Google Project Information
  google_project_id     = var.google_cloud_auth.google_project_id
  google_project_region = var.google_cloud_auth.google_project_region

  // Compute Resources
  compute_nodes         = var.gcloud_vpc1.compute
  ssh_username          = var.ssh_auth.username
  ssh_pubkey            = var.ssh_auth.pubkey

  // The Virtual Machines cannot be created until the networking is available.
  depends_on = [
    module.vpc1_networking
  ]
}
