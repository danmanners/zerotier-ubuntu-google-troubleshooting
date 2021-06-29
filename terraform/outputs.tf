// Print the Google Cloud Compute Public IPs for VPC 1
output "vpc1_compute" {
  value = module.vpc1_compute.ipv4
}

// Print the Google Cloud Compute Public IPs for VPC 2
output "vpc2_compute" {
  value = module.vpc2_compute.ipv4
}
