#!/bin/bash
set -e

RDP_PASSWORD="${RDP_PASSWORD:-1122}"

echo "========================================"
echo " Ubuntu MATE + XRDP"
echo "========================================"
echo "RDP user: ubuntu"
echo "========================================"

# Set the RDP password safely at every container start.
echo "ubuntu:${RDP_PASSWORD}" | chpasswd

# Ensure the user's home and runtime directories are usable.
mkdir -p /home/ubuntu /run/user/1000 /run/dbus /var/run/xrdp
chown -R ubuntu:ubuntu /home/ubuntu /run/user/1000
chown xrdp:xrdp /var/run/xrdp

# Start the system D-Bus daemon if it is not already running.
if ! pgrep -x dbus-daemon >/dev/null 2>&1; then
    dbus-daemon --system || true
fi

# Clean stale runtime files from a previous container process.
rm -f /var/run/xrdp/xrdp.pid
rm -f /var/run/xrdp/xrdp-sesman.pid

echo "Starting XRDP session manager..."
xrdp-sesman &

sleep 2

echo "Starting XRDP server on port 3389..."
exec xrdp --nodaemon
