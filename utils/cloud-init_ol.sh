#!/bin/bash

/usr/libexec/oci-growfs -y

dnf config-manager --enable ol8_kvm_appstream
dnf module enable -y virt:kvm_utils3
dnf install -y qemu-img

sudo pip3 install oci-cli
