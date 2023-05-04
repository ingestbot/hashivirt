#!/bin/sh

if [ -e /tmp/firstrun ]; then
 rm /tmp/firstrun
 reboot
fi
