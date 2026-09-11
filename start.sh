#!/bin/bash

set -e

# Default password if RDP_PASSWORD is not supplied.
# CHANGE THIS in Railway Variables.
RDP_PASSWORD="${RDP_PASSWORD:-ChangeMe123!}"

echo "======================================"
echo " Ubuntu XFCE + XRDP"
echo "======================================"
echo "User: railwayuser"
echo "Setting RDP password..."
echo "======================================"

# Set the password
echo "railwayuser:${RDP_PASSWORD}" | chpasswd

# Make sure the user owns their home directory
chown -R railwayuser:railwayuser /home/railwayuser

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
