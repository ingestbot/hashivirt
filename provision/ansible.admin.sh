#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

mkdir /etc/ssh/authorized_keys
chmod 755 /etc/ssh/authorized_keys

mv /tmp/ansible.admin /etc/ssh/authorized_keys/ansible.admin

chown ansible.admin /etc/ssh/authorized_keys/ansible.admin
chgrp ansible.admin /etc/ssh/authorized_keys/ansible.admin
chmod 400 /etc/ssh/authorized_keys/ansible.admin
echo 'AuthorizedKeysFile /etc/ssh/authorized_keys/%u' > /etc/ssh/sshd_config.d/00-provision_tmp.conf

systemctl restart ssh

cat >> /etc/environment <<EOF
http_proxy="http://proxy.sfio.win:8118"
https_proxy="http://proxy.sfio.win:8118"
EOF
