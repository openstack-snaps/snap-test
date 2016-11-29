#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q neutron || {
    sudo snap install --edge neutron
}

openstack user show neutron || {
    openstack user create --domain default --password neutron neutron
    openstack role add --project service --user neutron admin
}

openstack service show network || {
    openstack service create --name neutron \
      --description "OpenStack Network" network

    for endpoint in public internal admin; do
        openstack endpoint create --region RegionOne \
          network $endpoint http://localhost:9696 || :
    done
}

sudo cp -r $BASE_DIR/etc/neutron/common/* /var/snap/neutron/common

sudo neutron.manage upgrade head

sudo systemctl restart snap.neutron.*

while ! nc -z localhost 9696; do sleep 0.1; done;

neutron net-show test || {
    neutron net-create test
    neutron subnet-create subnet 192.168.222.0/24
}
