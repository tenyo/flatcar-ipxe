# Simple iPXE boot for Flatcar Linux

This is a really simple setup to get a bunch of bare metal machines at home booted via iPXE and initialized with Flatcar Linux. There are also a couple scripts included to quickly install Kubernetes and configure a basic cluster, although you don't have to use them. There are flatcar ignition configs for each machine that configure static IPs, hostnames and few other things that can be modified as needed.

## Pre-requisites

- Docker, docker-compose
- Butane (download from https://github.com/coreos/butane/releases)
- Machines that can boot from iPXE
- Some network planning (e.g. best to use a separate network for this, in this case I have `10.1.1.0/24`, default gateway `10.1.1.1` and a workstation running TFTP at `10.1.1.11`)

## Setup

- Update your `dhcpd.conf` to match your network setup

- Update files in `nginx/` with your specific IPs (e.g. `flatcar.ipxe` and `etc_hosts`). Also update the hex address dirs to match the MAC addresses of your machines and check the `boot.yaml` and `config.yaml` files inside each one.

- Regenerate ignition configs, e.g.

```
butane -s -p boot.yaml > boot.ign
butane -s -p config.yaml > config.ign
```

- Stage flatcar images

```
mkdir -p nginx/flatcar
cd nginx/flatcar
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz.sig
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz.sig
gpg --verify flatcar_production_pxe.vmlinuz.sig
gpg --verify flatcar_production_pxe_image.cpio.gz.sig
```

## Run

This will start DHCPD, TFTP and Nginx on your gateway machine:

```
docker compose up -d
```

Now boot your machines via iPXE and they should get an IP from the DHCP server, boot from TFTP and then download the flatcar pxe image and boot that with the given `boot.ign` ignition config. When they come up they should automatically install Flatcar Linux and reboot a couple times, then come up at a boot prompt when ready (flatcar autologin is enabled). You should be able to SSH into them using the SSH key provided in the configs.

### Kubernetes install

After you log in, you can install k8s pre-requisites by running `/opt/k8s_bootstrap.sh` (this should be run on control plane _and_ worker nodes). Assuming a cluster with 1 CP node, only run `/opt/k8s_init.sh` on that node and then join the rest of the workers.

