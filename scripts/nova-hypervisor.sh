#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q "^nova-hypervisor\s" || {
    sudo snap install --edge nova-hypervisor
}

# Manually connect interfaces if snap isn't installed from snap store.
# Otherwise, snap store automatically connects these interfaces.
interfaces=( firewall-control hardware-observe libvirt network-control
             network-observe openvswitch process-control system-observe )
for interface in "${interfaces[@]}"; do
    snap interfaces -i ${interface} nova-hypervisor | grep nova-hypervisor:${interface} && \
    sudo snap connect nova-hypervisor:${interface} core:${interface}
done

while sudo [ ! -d /var/snap/nova-hypervisor/common/etc/neutron/ ]; do sleep 0.1; done;
while sudo [ ! -d /var/snap/nova-hypervisor/common/etc/nova/ ]; do sleep 0.1; done;
sudo cp -r $BASE_DIR/etc/snap-nova-hypervisor/* /var/snap/nova-hypervisor/common/etc/

sudo systemctl restart snap.nova-hypervisor.*
sudo systemctl restart snap.nova-hypervisor.nova-compute

# Manually define alias if snap isn't installed from snap store.
# Otherwise, snap store defines this alias automatically.
snap aliases nova | grep nova-manage || sudo snap alias nova.manage nova-manage

sudo nova-manage cell_v2 discover_hosts --verbose
