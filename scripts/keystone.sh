#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q keystone || {
    sudo snap install --edge keystone
}

sudo cp -r $BASE_DIR/etc/keystone/common/* /var/snap/keystone/common

sudo keystone.manage fernet_setup --keystone-user root --keystone-group root
sudo keystone.manage db_sync

sudo systemctl restart snap.keystone.*

openstack user show admin || {
    sudo keystone.manage bootstrap \
        --bootstrap-password keystone \
        --bootstrap-admin-url http://localhost:35357/v3/ \
        --bootstrap-internal-url http://localhost:35357/v3/ \
        --bootstrap-public-url http://localhost:5000/v3/ \
        --bootstrap-region-id RegionOne
}

openstack project show service || {
    openstack project create --domain default --description "Service Project" service
}
