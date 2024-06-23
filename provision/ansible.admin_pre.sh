#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

groupadd -g 7000 ansible.admin
useradd -g 7000 -u 7000 ansible.admin
usermod -a -G sudo ansible.admin

mkdir /etc/ssh/authorized_keys
chmod 755 /etc/ssh/authorized_keys
