#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q "^nova-hypervisor\s" || {
    sudo snap install --edge --devmode nova-hypervisor
}

sudo cp -r $BASE_DIR/etc/nova-hypervisor/common/* /var/snap/nova-hypervisor/common

sudo systemctl restart snap.nova-hypervisor.*
