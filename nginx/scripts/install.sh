#!/bin/bash
# Install flatcar linux and customize filesystem
# By default flatcar-install will use all available space on the ROOT partition (9).
# This script modifies it to 50G and creates another partition (10) that could be used for other things (such as ceph).
# NOTE: this assumes there's only a single disk when doing fdisk, but should work with most disks, e.g. /dev/sda or /dev/nvme0n1

set -e

# install on the smallest avalable disk (major types 8 or 259)
flatcar-install -s -I 8,259 -i /opt/config.ign

# recreate partition 9 as 50GB and add partition 10 for all available space
DISK=$(lsblk -I 8,259 --nodeps -n -o name)
fdisk /dev/${DISK} <<EOF
d
9
n
9

+50G
n
10


w
EOF

udevadm settle

# resize partition 9 to take all available space
PART9=$(lsblk -I 8,259 -n -l -o name | grep 9)
resize2fs /dev/${PART9}

udevadm settle

systemctl reboot

