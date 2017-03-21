#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q "^nova-hypervisor\s" || {
    sudo snap install --edge --devmode nova-hypervisor
}

while [ ! -d /var/snap/nova-hypervisor/common/etc/neutron/ ]; do sleep 0.1; done;
sudo cp -r $BASE_DIR/etc/nova-hypervisor/neutron/* /var/snap/nova-hypervisor/common/etc/neutron/
while [ ! -d /var/snap/nova-hypervisor/common/etc/nova/ ]; do sleep 0.1; done;
sudo cp -r $BASE_DIR/etc/nova-hypervisor/nova/* /var/snap/nova-hypervisor/common/etc/nova/

for i in `snap interfaces | grep "^-" | awk '{ print $2 }' | cut -d : -f 2 `; do
    sudo snap connect nova-hypervisor:$i core:$i
done

sudo systemctl restart snap.nova-hypervisor.*

# Needs support in snap.openstack for perms on directories created.
sudo chmod a+rx /var/snap/nova-hypervisor/common/instances
