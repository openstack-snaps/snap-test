#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q "^nova-hypervisor\s" || {
    sudo snap install --edge nova-hypervisor
}

while sudo [ ! -d /var/snap/nova-hypervisor/common/etc/neutron/ ]; do sleep 0.1; done;
while sudo [ ! -d /var/snap/nova-hypervisor/common/etc/nova/ ]; do sleep 0.1; done;
sudo cp -r $BASE_DIR/etc/snap-nova-hypervisor/* /var/snap/nova-hypervisor/common/etc/

sudo systemctl restart snap.nova-hypervisor.*

# Needs support in snap.openstack for perms on directories created.
sudo chmod a+rx /var/snap/nova-hypervisor/common/instances

sudo nova.manage cell_v2 discover_hosts --verbose
