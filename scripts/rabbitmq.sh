#!/bin/bash

set -ex

sudo rabbitmqctl add_user openstack rabbitmq
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
