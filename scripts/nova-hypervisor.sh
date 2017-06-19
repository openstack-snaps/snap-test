#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q "^nova-hypervisor\s" || {
    sudo snap install --edge nova-hypervisor
}

# NOTE(coreycb): These are temporary until the nova-hypervisor snap gets
# auto-connect support in the snap store for these interfaces.
sudo snap connect nova-hypervisor:system-trace core:system-trace
sudo snap connect nova-hypervisor:hardware-observe core:hardware-observe
sudo snap connect nova-hypervisor:system-observe core:system-observe
sudo snap connect nova-hypervisor:process-control core:process-control
sudo snap connect nova-hypervisor:openvswitch core:openvswitch
sudo snap connect nova-hypervisor:libvirt core:libvirt
sudo snap connect nova-hypervisor:network-observe core:network-observe
sudo snap connect nova-hypervisor:network-control core:network-control
sudo snap connect nova-hypervisor:firewall-control core:firewall-control

while sudo [ ! -d /var/snap/nova-hypervisor/common/etc/neutron/ ]; do sleep 0.1; done;
while sudo [ ! -d /var/snap/nova-hypervisor/common/etc/nova/ ]; do sleep 0.1; done;
sudo cp -r $BASE_DIR/etc/snap-nova-hypervisor/* /var/snap/nova-hypervisor/common/etc/

sudo systemctl restart snap.nova-hypervisor.*

sudo nova.manage cell_v2 discover_hosts --verbose
