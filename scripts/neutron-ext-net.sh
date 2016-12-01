#!/bin/bash

set -ex

source $BASE_DIR/admin-openrc

sudo ovs-vsctl --may-exist add-br br-ex

# Create bridge for local access to instances
sudo brctl addbr br-dw || :
sudo ip addr flush br-dw
sudo ip addr add 10.30.20.1/24 dev br-dw
sudo ip link set br-dw up

# Wire linux bridge to ovs bridge
sudo ip link add dodgy-wiring0 type veth peer name dodgy-wiring1 || :
sudo brctl addif br-dw dodgy-wiring1 || :
sudo ovs-vsctl --may-exist add-port br-ex dodgy-wiring0

sudo ip link set dodgy-wiring1 up
sudo ip link set dodgy-wiring0 up

neutron net-show ext_net || {
    neutron net-create --provider:network_type=flat --provider:physical_network physnet1 \
        --router:external ext_net
    neutron subnet-create --gateway 10.30.20.1 \
        --dns-nameserver 10.30.20.1 --disable-dhcp \
        ext_net 10.30.20.0/24
}
