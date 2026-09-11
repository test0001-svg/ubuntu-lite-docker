FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install XFCE desktop, XRDP, Xorg and required utilities
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xorg \
    xrdp \
    dbus-x11 \
    sudo \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create RDP user
RUN useradd -m -s /bin/bash railwayuser && \
    usermod -aG sudo railwayuser

# Configure Xorg/XRDP
RUN sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config

# Configure XFCE session for the RDP user
RUN echo "startxfce4" > /home/railwayuser/.xsession && \
    chown railwayuser:railwayuser /home/railwayuser/.xsession && \
    chmod 644 /home/railwayuser/.xsession

# Configure XRDP to start XFCE
RUN cat > /etc/xrdp/startwm.sh <<'EOF'
#!/bin/sh

unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR

exec startxfce4
EOF

RUN chmod +x /etc/xrdp/startwm.sh

# Create startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# XRDP internal port
EXPOSE 3389

# Start XRDP
CMD ["/start.sh"]
