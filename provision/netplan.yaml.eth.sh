#!/bin/sh

# MYIPADDR=$( host `hostname` | awk {'print $4'} )
MYIPADDR=$( dig +short @192.168.121.1 `hostname`.sfio.win )

if [ -z "${MYIPADDR}" ]; then
    echo "ERROR: Unable to determine IP address for $(hostname).sfio.win"
    exit 1
fi

MYGATEWAY=$( printf '%s\n' $MYIPADDR | awk -F"." '{print $1"."$2"."$3".1"}' )
MYVLAN=$( printf '%s\n' $MYIPADDR | awk -F"." '{print $3 }' )
# NETPLANCONFIG_OS=/etc/netplan/00-installer-config.yaml
NETPLANCONFIG_OS=/etc/netplan/01-dhcp-all-ethernets.yaml
NETPLANCONFIG_VAGRANT=/etc/netplan/50-vagrant.yaml
NETPLANCONFIG=/etc/netplan/01-netcfg.yaml

if [ -e ${NETPLANCONFIG_OS} ]; then
 mv ${NETPLANCONFIG_OS} ${NETPLANCONFIG_OS}.ORIG
fi

if [ -e ${NETPLANCONFIG_VAGRANT} ]; then
 mv ${NETPLANCONFIG_VAGRANT} ${NETPLANCONFIG_VAGRANT}.ORIG
fi

if [ -e ${NETPLANCONFIG} ]; then
 cp ${NETPLANCONFIG} ${NETPLANCONFIG}.ORIG
fi

# if [ "${MYVLAN}" = 1 ]; then

##
## 6/22/2024 - When disabling ipv6 an issue was raised with degraded boot/init/start time whereby
## systemd-networkd-wait-online.service would timeout/fail. Described here:
##   https://bugs.launchpad.net/ufw/+bug/2070087
##
## The resolution involved removing the unused interface ens5: {} and adding link-local: [ ]
##

/bin/cat <<EoM >${NETPLANCONFIG}
network:
  version: 2
  renderer: networkd
  ethernets:
    ens5:
      dhcp4: true
      dhcp6: true
    ens6:
      link-local: [ ]
      addresses: [${MYIPADDR}/24]
      routes:
        - to: default
          via: ${MYGATEWAY}
EoM

chmod 600 "${NETPLANCONFIG}"

# Generate and apply the new network configuration.
/usr/sbin/netplan generate || exit 1
/usr/sbin/netplan apply || exit 1
