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
sudo systemctl restart snap.nova-hypervisor.nova-compute

sudo nova-manage cell_v2 discover_hosts --verbose
