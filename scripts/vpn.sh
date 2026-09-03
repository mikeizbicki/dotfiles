#!/bin/sh

sudo /sbin/openconnect \
    --user=mizbicki@cmc.edu \
    --protocol=anyconnect \
    https://vpn.claremontmckenna.edu/ \
    --os=win \
    --useragent='AnyConnect Windows 4.9.00086' \
    --no-external-auth \
    --script=$HOME/scripts/vpnc-fixdns.sh
