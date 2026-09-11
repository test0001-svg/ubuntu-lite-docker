#!/bin/bash

set -e

# Default RDP password. Override at runtime with the RDP_PASSWORD variable
# (e.g. a Railway variable) - the username is always "ubuntu".
RDP_PASSWORD="${RDP_PASSWORD:-1122}"

echo "========================================"
echo " Ubuntu MATE (24.04 LTS) + XRDP"
echo "========================================"
echo "RDP user: ubuntu"
echo "========================================"

# Apply the password on every boot (default: 1122)
HASH=$(openssl passwd -6 -salt xrdp1122 "$RDP_PASSWORD")
DAYS=$(( $(date +%s) / 86400 ))
grep -v '^ubuntu:' /etc/shadow > /tmp/sh.new
echo "ubuntu:${HASH}:${DAYS}:0:99999:7:::" >> /tmp/sh.new
cat /tmp/sh.new > /etc/shadow
rm -f /tmp/sh.new

# Make sure the user owns their home directory
chown -R ubuntu:ubuntu /home/ubuntu

# Start D-Bus system daemon if needed
mkdir -p /run/dbus

if ! pgrep -x dbus-daemon >/dev/null 2>&1; then
    dbus-daemon --system || true
fi

# Clean up stale XRDP files
rm -f /var/run/xrdp/xrdp.pid
rm -f /var/run/xrdp/xrdp-sesman.pid

# Make sure XRDP runtime directory exists
mkdir -p /var/run/xrdp
chown xrdp:xrdp /var/run/xrdp

echo "Starting XRDP session manager..."

# Start XRDP session manager
xrdp-sesman &

sleep 2

echo "Starting XRDP server on port 3389..."

# Keep XRDP in foreground so Railway keeps the container alive
exec xrdp --nodaemon
