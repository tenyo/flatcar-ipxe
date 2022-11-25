# Simple iPXE boot for Flatcar Linux

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


