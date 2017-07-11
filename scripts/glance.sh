#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

snap list | grep -q glance || {
    sudo snap install --edge glance
}

while sudo [ ! -d /var/snap/glance/common/etc/glance/ ]; do sleep 0.1; done;
sudo cp -r $BASE_DIR/etc/snap-glance/* /var/snap/glance/common/etc/

openstack user show glance || {
    openstack user create --domain default --password glance glance
    openstack role add --project service --user glance admin
}

openstack service show image || {
    openstack service create --name glance --description "OpenStack Image" image
    for endpoint in internal admin public; do
        openstack endpoint create --region RegionOne \
            image $endpoint http://localhost:9292 || :
    done
}

# Manually define alias if snap isn't installed from snap store.
# Otherwise, snap store defines this alias automatically.
snap aliases glance | grep glance-manage || sudo snap alias glance.manage glance-manage

sudo glance-manage db_sync

sudo systemctl restart snap.glance.*

while ! nc -z localhost 9292; do sleep 0.1; done;

openstack image show xenial || {
    [ -f $HOME/images/xenial-server-cloudimg-amd64-disk1.img ] || {
        mkdir -p $HOME/images
        wget http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img \
            -O ${HOME}/images/xenial-server-cloudimg-amd64-disk1.img
    }
    openstack image create --file ${HOME}/images/xenial-server-cloudimg-amd64-disk1.img \
        --public --container-format=bare --disk-format=qcow2 xenial
}
