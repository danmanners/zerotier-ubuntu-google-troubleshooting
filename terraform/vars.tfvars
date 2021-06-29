google_cloud_auth = {
  // Google Cloud
  google_project_id     = "booming-tooling-291422"
  google_project_region = "us-east4"
}

ssh_auth = {
  // username  = "YourUserName"
  // pubkey    = "YourSSHPubkeyHere"
  username  = "danmanners"
  pubkey    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAngYLcPg5iIOgxoVae6JUr3gyqB4QBufth6oNc+II0D Dan Manners <daniel.a.manners@gmail.com>"
}

// ##################################################################################################
// # subnetwork name format: "projects/$google_project_id/regions/$region/subnetworks/$name
// # EXAMPLE:                "projects/booming-tooling-291422/regions/us-east4/subnetworks/public-1a"
// ##################################################################################################

gcloud_vpc1 = {
  "vpc_name" = "vpc1"
  "vpc_public_subnets" = {
    "public-1a" = {
      ip_cidr_range = "192.168.0.0/24"
      description   = "VPC 1 - Two Compute Instances"
    }
  },
  ingress_rules = {
    name = "vpc-1"
    direction = "ingress"
    target_tags = ["vpc1"]
    allow_blocks = {
      icmp = {
        protocol = "icmp"
      }
      tcp = {
        protocol = "tcp"
        ports = ["22","80","443","6443"]
      }
    }
  },
  compute = [
    {
      "name"            = "zerotier-router"
      "zone"            = "a"
      "vm_type"         = "e2-micro"
      "boot_disk_size"  = 16
      "host_os"         = "ubuntu-os-cloud/ubuntu-2004-lts"
      "network"         = {
        // Update the subnetwork below
        "subnetwork"    = "projects/booming-tooling-291422/regions/us-east4/subnetworks/public-1a"
        "tier"          = "standard"
      }
      "tags"            = ["vpc1"]
    },
    {
      "name"            = "k3s-controlplane"
      "zone"            = "a"
      "vm_type"         = "e2-small"
      "boot_disk_size"  = 16
      "host_os"         = "ubuntu-os-cloud/ubuntu-2004-lts"
      "network"         = {
        // Update the subnetwork below
        "subnetwork"    = "projects/booming-tooling-291422/regions/us-east4/subnetworks/public-1a"
        "tier"          = "standard"
      }
      "tags"            = ["vpc1"]
    }
  ]
}

gcloud_vpc2 = {
  "vpc_name" = "vpc2"
  "vpc_public_subnets" = {
    "public-1b" = {
      ip_cidr_range = "192.168.1.0/24"
      description = "VPC 2"
    }
  },
  ingress_rules = {
    name = "vpc-2"
    direction = "ingress"
    target_tags = ["vpc2"]
    allow_blocks = {
      icmp = {
        protocol = "icmp"
      }
      tcp = {
        protocol = "tcp"
        ports = ["22","80","443","6443"]
      }
    }
  },
  compute = [
    {
      "name"            = "k3s-node"
      "zone"            = "b"
      "vm_type"         = "e2-micro"
      "boot_disk_size"  = 16
      "host_os"         = "ubuntu-os-cloud/ubuntu-2004-lts"
      "network"         = {
        // Update the subnetwork below
        "subnetwork"    = "projects/booming-tooling-291422/regions/us-east4/subnetworks/public-1b"
        "tier"          = "standard"
      }
      "tags"            = ["vpc2"]
    }
  ] 
}
