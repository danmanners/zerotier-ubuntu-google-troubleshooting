# Zerotier Memory Growth until System Locks Up

This repo should allow anyone to clone it and replicate a ZeroTier memory leak with version 1.6.5 on Google Cloud Ubuntu 20.04 hosts when running K3s. I created an issue on Github ([ZeroTierOne/#1432](https://github.com/zerotier/ZeroTierOne/issues/1423))

<center><img src="readme/network.png" width="500px"/></center>

## Software Requirements

- Terraform v1.0.0+
- Kubectl
- Zerotier Account
- Zerotier Network
- Google Cloud Account
- Google Cloud CLI Tool (Login with `gcloud auth application-default login`)
- SSH Keypair

## Infrastructure Setup

To try to simulate my homelab, Terraform will provision:

- Two different Subnets in Google Cloud
- Three different compute instances
  - One in Subnet 1
  - Two in Subnet 2

In the `terraform` directory, you'll need to update the `vars.tfvars` file.

When you're ready to set up your infrastructure, run:

```bash
terraform init
terraform apply -var-file=vars.tfvars

# When it's complete, you should get output similar to this:
...
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

vpc1_compute = {
  "k3s-controlplane" = "35.212.98.22"
  "zerotier-router" = "35.212.111.73"
}
vpc2_compute = {
  "k3s-node" = "35.212.94.125"
}
```

## Create your ZeroTier Network

[In the ZeroTier console](https://my.zerotier.com), create a network and get the Network ID.

## Zerotier Router Provisioning

Provision your Zerotier router with the steps [roughly listed here](https://www.danmanners.com/posts/p2-k3s-digitalocean-zerotier-and-more/#zerotier).

This might look like:

```bash
# Install Zerotier and join to the previous network
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join ba0348ec2d6679b4

# Ensure that we can forward packets between interfaces
sudo sysctl net.ipv4.ip_forward=1
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Set up iptables rules
ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'
# eth0        <== This is our physical ethernet
# ztyou2j6dw  <==This is our Zerotier Virtual Adapter
PHY_IFACE="eth0"
ZT_IFACE="$(ip l | grep 'zt' | awk '{print substr($2,1,length($2)-1)}')" # <== This command will grab your ZeroTier interface name
sudo iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
sudo iptables -A FORWARD -i $PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $ZT_IFACE -o $PHY_IFACE -j ACCEPT

# Make sure the rules are persistent after reboot/poweroff
sudo apt install iptables-persistent
sudo bash -c iptables-save > /etc/iptables/rules.v4

# Ensure that Zerotier always comes back up after a reboot
sudo systemctl enable zerotier-one
```

Back on the ZeroTier Network, you'll want to add a Managed Route with the destination of `192.168.0.0/24` via the IP of your ZeroTier Router IP address (the zerotier IP, not the host IP).

## K3s Control Plane

On your `k3s-controlplane` vm, you can set up a static route to be able to reach the `k3s-node` host by running:

```bash
sudo ip route add 192.168.1.0/24 via $zerotier_router_internal_ip
```

## K3s Control Plane

```bash
sudo wget https://github.com/k3s-io/k3s/releases/download/v1.21.2%2Bk3s1/k3s -O /usr/local/bin/k3s
sudo chmod a+x /usr/local/bin/k3s
sudo mkdir -p /etc/rancher/k3s
```

## Destorying Infrastructure

You can destroy your Terraform infrastructure by running the following command from the `terraform` directory:

```bash
terraform destroy -var-file=vars.tfvars
```
