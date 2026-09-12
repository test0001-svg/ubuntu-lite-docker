FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Ubuntu MATE desktop + XRDP/Xorg + utilities
RUN apt-get update && apt-get install -y \
    ubuntu-mate-desktop \
    xrdp \
    xorg \
    xorgxrdp \
    dbus-x11 \
    dbus \
    sudo \
    curl \
    ca-certificates \
    openssl \
    x11-xserver-utils \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Mozilla Firefox ESR without Snap (Snap/systemd is not suitable for this container)
RUN curl -fsSL "https://download.mozilla.org/?product=firefox-esr-latest&os=linux64&lang=en-US" \
    -o /tmp/firefox.tar.xz \
    && tar xJf /tmp/firefox.tar.xz -C /opt \
    && rm -f /tmp/firefox.tar.xz \
    && printf '#!/bin/sh\nexec /opt/firefox/firefox "$@"\n' > /usr/bin/firefox-esr \
    && chmod 755 /usr/bin/firefox-esr \
    && printf '%s\n' \
       '[Desktop Entry]' \
       'Name=Firefox Web Browser' \
       'Comment=Browse the Web' \
       'Exec=firefox-esr %u' \
       'Terminal=false' \
       'Icon=/opt/firefox/browser/chrome/icons/default/default128.png' \
       'Type=Application' \
       'Categories=Network;WebBrowser;' \
       'MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;' \
       'StartupNotify=true' \
       > /usr/share/applications/firefox-esr.desktop \
    && update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox-esr 100 \
    && update-alternatives --set x-www-browser /usr/bin/firefox-esr \
    && update-alternatives --install /usr/bin/www-browser www-browser /usr/bin/firefox-esr 100 \
    && update-alternatives --set www-browser /usr/bin/firefox-esr \
    && printf '%s\n' \
       '[Default Applications]' \
       'x-scheme-handler/http=firefox-esr.desktop' \
       'x-scheme-handler/https=firefox-esr.desktop' \
       'text/html=firefox-esr.desktop' \
       > /etc/mimeapps.list

# RDP account: keep Linux login name "ubuntu"; display/full name is "Ubuntu MATE".
RUN if id ubuntu >/dev/null 2>&1; then \
        usermod -s /bin/bash ubuntu; \
    else \
        useradd -m -s /bin/bash ubuntu; \
    fi \
    && mkdir -p /home/ubuntu \
    && usermod -c 'Ubuntu MATE' ubuntu \
    && usermod -aG sudo ubuntu \
    && echo 'ubuntu:1122' | chpasswd \
    && chown -R ubuntu:ubuntu /home/ubuntu

# XRDP must start a real per-session D-Bus + MATE session.
RUN printf '%s\n' \
       '#!/bin/sh' \
       'export LANG=C.UTF-8' \
       'export LANGUAGE=C.UTF-8' \
       'export LC_ALL=C.UTF-8' \
       'export XDG_CURRENT_DESKTOP=MATE' \
       'export XDG_SESSION_DESKTOP=mate' \
       'export DESKTOP_SESSION=mate' \
       'export XDG_CONFIG_DIRS=/etc/xdg/xdg-mate:/etc/xdg' \
       'export XDG_DATA_DIRS=/usr/share/mate:/usr/share/ubuntu-mate:/usr/local/share:/usr/share' \
       'unset DBUS_SESSION_BUS_ADDRESS' \
       'unset XDG_RUNTIME_DIR' \
       'exec dbus-run-session -- /usr/bin/mate-session' \
       > /etc/xrdp/startwm.sh \
    && chmod 755 /etc/xrdp/startwm.sh \
    && printf '%s\n' \
       'mate-session' \
       > /home/ubuntu/.xsession \
    && chown ubuntu:ubuntu /home/ubuntu/.xsession \
    && if [ -f /etc/X11/Xwrapper.config ]; then \
         sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config; \
       else \
         printf '%s\n' 'allowed_users=anybody' 'needs_root_rights=yes' > /etc/X11/Xwrapper.config; \
       fi

# Prepare MATE's runtime/config directories.
RUN mkdir -p /home/ubuntu/.config \
    && cp /etc/mimeapps.list /home/ubuntu/.config/mimeapps.list \
    && mkdir -p /run/user/1000 \
    && chown -R ubuntu:ubuntu /home/ubuntu /run/user/1000 \
    && runuser -u ubuntu -- env XDG_RUNTIME_DIR=/run/user/1000 \
       dbus-run-session -- sh -c '\
         gsettings set org.mate.interface gtk-theme "Yaru-MATE-dark" && \
         gsettings set org.mate.interface icon-theme "Yaru-MATE-dark" && \
         (gsettings set org.mate.interface color-scheme "prefer-dark" || true) && \
         gsettings set org.mate.background picture-options "zoom" || true'

# Disable only hardware/service components that are inappropriate in a container.
# Keep the MATE panel, menu, Caja, settings daemon, notifications, and normal apps.
RUN for f in mate-power-manager \
             ayatana-indicator-power \
             ayatana-indicator-printers \
             print-applet; do \
        if [ -f "/etc/xdg/autostart/$f.desktop" ]; then \
            mv "/etc/xdg/autostart/$f.desktop" "/etc/xdg/autostart/$f.desktop.disabled"; \
        fi; \
    done

# Avoid the Ubuntu crash-report popup in a container.
RUN mkdir -p /etc/default \
    && printf '%s\n' \
       '# Disable Apport crash-report UI in the container.' \
       'enabled=0' \
       > /etc/default/apport \
    && rm -f /var/crash/*

# Apply security/bug-fix updates at build time.
RUN apt-get update \
    && apt-get -y full-upgrade \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 3389
CMD ["/start.sh"]
