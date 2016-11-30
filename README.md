# snap-test

A script for testing OpenStack snap packages on a single node.

To install OpenStack using snaps:

    ./snap-deploy

Once the snaps are installed and configured you can access the
cloud using:

    source admin-openrc
    openstack server create --flavor m1.small --image xenial test-instance

The cloud is configured with Keystone v3 authentication, and includes
identity, image, compute and networking services.
