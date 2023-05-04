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

/bin/cat <<EoM >${NETPLANCONFIG}
network:
  version: 2
  renderer: networkd
  ethernets:
    ens5: {}
    ens6:
      addresses: [${MYIPADDR}/24]
      routes:
        - to: default
          via: ${MYGATEWAY}
EoM
