# mkdir -p "/tmp/packer-tmp"
# chmod 700 "/tmp/packer-tmp"
# TMPDIR="/tmp/packer-tmp" packer build packer.json

TMPDIR="/var/tmp" packer build packer.json

