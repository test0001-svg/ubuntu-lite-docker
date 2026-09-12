#!/bin/bash
set -e
RDP_PASSWORD="${RDP_PASSWORD:-1122}"
echo "Ubuntu MATE + XRDP + Plank"
echo "RDP user: ubuntu"
echo "ubuntu:${RDP_PASSWORD}" | chpasswd
mkdir -p /home/ubuntu /run/user/1000 /run/dbus /var/run/xrdp
chown -R ubuntu:ubuntu /home/ubuntu /run/user/1000
chown xrdp:xrdp /var/run/xrdp
if ! pgrep -x dbus-daemon >/dev/null 2>&1; then dbus-daemon --system || true; fi
rm -f /var/run/xrdp/xrdp.pid /var/run/xrdp/xrdp-sesman.pid
echo "Starting XRDP session manager..."
xrdp-sesman &
sleep 2
echo "Starting XRDP server on port 3389..."
exec xrdp --nodaemon
