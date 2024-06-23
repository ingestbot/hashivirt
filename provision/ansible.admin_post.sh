#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

mv /tmp/ansible.admin /etc/ssh/authorized_keys/ansible.admin

chown ansible.admin /etc/ssh/authorized_keys/ansible.admin
chgrp ansible.admin /etc/ssh/authorized_keys/ansible.admin
chmod 400 /etc/ssh/authorized_keys/ansible.admin
echo 'AuthorizedKeysFile /etc/ssh/authorized_keys/%u' > /etc/ssh/sshd_config.d/00-provision_tmp.conf

echo 'ansible.admin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99_ansible_admin
chmod 640 /etc/sudoers.d/99_ansible_admin

##
## 4/19/2024 - Disabling cloud-init 
##
touch /etc/cloud/cloud-init.disabled

##
## 6/7/2024 - Quick hack to enable systemd-resolved
## 
echo 'DNS=192.168.1.25 192.168.1.10' >> /etc/systemd/resolved.conf
echo 'Domains=sfio.win' >> /etc/systemd/resolved.conf

##
##
##
sudo apt-get update
