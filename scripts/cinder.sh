#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q cinder || {
    sudo snap install --channel=ocata/edge cinder
}

while sudo [ ! -d /var/snap/cinder/common/etc/cinder/ ]; do sleep 0.1; done;
sudo cp -r $BASE_DIR/etc/snap-cinder/cinder/* /var/snap/cinder/common/etc/
sudo cp -r $BASE_DIR/etc/snap-cinder/tgt/* /etc/tgt/

openstack user show cinder || {
    openstack user create --domain default --password cinder cinder
    openstack role add --project service --user cinder admin
}

openstack service show volumev2 || {
    openstack service create --name cinderv2 \
      --description "OpenStack Block Storage" volumev2

    for endpoint in internal admin public; do
        openstack endpoint create --region RegionOne \
            volumev2 $endpoint http://localhost:8776/v2/%\(project_id\)s || :
    done
}

openstack service show volumev3 || {
    openstack service create --name cinderv3 \
      --description "OpenStack Block Storage" volumev3

    for endpoint in internal admin public; do
        openstack endpoint create --region RegionOne \
            volumev3 $endpoint http://localhost:8776/v3/%\(project_id\)s || :
    done
}

# Manually define alias if snap isn't installed from snap store.
# Otherwise, snap store defines this alias automatically.
snap aliases cinder | grep cinder-manage || sudo snap alias cinder.manage cinder-manage

sudo cinder-manage db sync

# Create a file-based loopback device with the cinder volume group on it
if [ ! -e /var/cinder/cinder-volumes-file ]; then
    sudo mkdir -p /var/cinder
    sudo truncate -s 4096M /var/cinder/cinder-volumes-file
    loop_dev=$(sudo losetup -f --show /var/cinder/cinder-volumes-file)
    sudo vgcreate cinder-volumes $loop_dev
    sudo vgs cinder-volumes
fi

sudo systemctl restart tgt
sudo systemctl restart snap.cinder.*

while ! nc -z localhost 8776; do sleep 0.1; done;
