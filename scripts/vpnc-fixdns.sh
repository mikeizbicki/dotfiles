#!/bin/sh
/usr/share/vpnc-scripts/vpnc-script "$@" || exit $?
case "$reason" in
  connect|reconnect) printf 'nameserver 8.8.8.8\n' > /etc/resolv.conf ;;
esac
