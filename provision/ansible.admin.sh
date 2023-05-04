#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

HTTPSERVER="192.168.1.25"

groupadd -g 7000 ansible.admin
useradd -g 7000 -u 7000 ansible.admin
usermod -a -G sudo ansible.admin

mkdir -p /home/ansible.admin/.ssh

curl -k -so /home/ansible.admin/.ssh/authorized_keys https://${HTTPSERVER}/admin/ssh/ansible.admin.ssh.pub.key 

chown -R ansible.admin /home/ansible.admin
chgrp -R ansible.admin /home/ansible.admin
chmod 700 /home/ansible.admin/.ssh
chmod 400 /home/ansible.admin/.ssh/authorized_keys

echo 'ansible.admin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99_ansible_admin
