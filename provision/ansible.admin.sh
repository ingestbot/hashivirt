#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

HTTPSERVER="192.168.1.25"

groupadd -g 7000 ansible.admin
useradd -g 7000 -u 7000 ansible.admin
usermod -a -G sudo ansible.admin

mkdir /etc/ssh/authorized_keys
chmod 755 /etc/ssh/authorized_keys
curl -k -so /etc/ssh/authorized_keys/ansible.admin https://${HTTPSERVER}/admin/ssh/ansible.admin.ssh.pub.key
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
