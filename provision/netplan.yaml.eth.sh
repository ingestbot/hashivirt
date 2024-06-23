#!/bin/sh

# MYIPADDR=$( host `hostname` | awk {'print $4'} )
MYIPADDR=$( dig +short @192.168.121.1 `hostname`.sfio.win )

MYGATEWAY=$( printf '%s\n' $MYIPADDR | awk -F"." '{print $1"."$2"."$3".1"}' )
MYVLAN=$( printf '%s\n' $MYIPADDR | awk -F"." '{print $3 }' )
NETPLANCONFIG_OS=/etc/netplan/00-installer-config.yaml
NETPLANCONFIG=/etc/netplan/01-netcfg.yaml

if [ -e ${NETPLANCONFIG_OS} ]; then
 mv ${NETPLANCONFIG_OS} ${NETPLANCONFIG_OS}.ORIG
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
    ens6:
      link-local: [ ]
      addresses: [${MYIPADDR}/24]
      routes:
        - to: default
          via: ${MYGATEWAY}
EoM
