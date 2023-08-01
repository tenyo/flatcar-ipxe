#!/bin/bash
# Install rook-ceph

helm repo add rook-release https://charts.rook.io/release

# install operator
helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph

# create values override config
cat <<EOF | tee /tmp/rook-ceph-values.yaml
---
cephClusterSpec:
  cephVersion:
    image: quay.io/ceph/ceph:v18
  mon:
    count: 3
    allowMultiplePerNode: false
  mgr:
    count: 2
    allowMultiplePerNode: false
  storage: # cluster level storage configuration and selection
    useAllNodes: true
    useAllDevices: false
    deviceFilter: "sda10|nvme0n1p10"
    config:
      # databaseSizeMB: "1024" # uncomment if the disks are smaller than 100 GB
      # journalSizeMB: "1024"  # uncomment if the disks are 20 GB or smaller
      osdsPerDevice: "1"
      encryptedDevice: "false"
  dashboard:
    enabled: true
    port: 8443
    ssl: true
toolbox:
  enabled: true
EOF

# create ceph cluster
helm install --create-namespace --namespace rook-ceph rook-ceph-cluster \
   --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster -f /tmp/rook-ceph-values.yaml

