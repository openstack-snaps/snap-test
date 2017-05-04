#!/bin/bash

set -ex

sudo rabbitmqctl list_users | grep openstack || sudo rabbitmqctl add_user openstack rabbitmq
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
