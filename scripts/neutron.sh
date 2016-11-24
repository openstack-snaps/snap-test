#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q neutron || {
    sudo snap install --edge neutron
}

sudo cp -r $BASE_DIR/etc/neutron/common/* /var/snap/neutron/common

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

openstack image show xenial || {
    openstack image create --file ${HOME}/images/xenial-server-cloudimg-amd64-disk1.img \
        --public --container-format=bare --disk-format=qcow2 xenial
}

sudo cp neutron.conf.d/* /var/snap/neutron/common/etc/neutron.conf.d/

sudo neutron.manage db sync
sudo neutron.manage api_db sync

sudo systemctl restart snap.neutron.*

