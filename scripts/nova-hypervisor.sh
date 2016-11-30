#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q "^nova-hypervisor\s" || {
    sudo snap install --edge --devmode nova-hypervisor
}

sudo cp -r $BASE_DIR/etc/nova-hypervisor/common/* /var/snap/nova-hypervisor/common

for i in `snap interfaces | grep "^-" | awk '{ print $2 }' | cut -d : -f 2 `; do
    sudo snap connect nova-hypervisor:$i ubuntu-core:$i
done

# Needs support in snap.openstack for perms on directories created.
chmod a+rx /var/snap/nova-hypervisor/common/instances

sudo systemctl restart snap.nova-hypervisor.*
