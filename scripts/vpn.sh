#!/bin/sh

/sbin/openconnect --user=mizbicki@cmc.edu --protocol=anyconnect https://vpn.claremontmckenna.edu/ --os=win --useragent='AnyConnect Windows 4.9.00086' --no-external-auth

# FIXME:
# this needs to be manually typed into a different terminal to fix DNS issues with the VPN
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
