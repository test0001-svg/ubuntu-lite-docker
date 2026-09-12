FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Stock Ubuntu MATE desktop + XRDP + Xorg
RUN apt-get update && apt-get install -y \
    ubuntu-mate-desktop \
    xrdp \
    xorg \
    xorgxrdp \
    dbus-x11 \
    sudo \
    curl \
    ca-certificates \
    openssl \
    x11-xserver-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Real Firefox ESR (Snap Firefox does not work correctly in a normal
# Docker/Railway container because Snap expects systemd).
RUN curl -fsSL "https://download.mozilla.org/?product=firefox-esr-latest&os=linux64&lang=en-US" -o /tmp/firefox.tar.xz \
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

# RDP account.
# ubuntu-mate-desktop can create an "ubuntu" account in some package
# configurations, so do NOT blindly run useradd. Make this step idempotent.
# Default RDP credentials:
#   username: ubuntu
#   password: 1122
RUN if id ubuntu >/dev/null 2>&1; then \
        usermod -s /bin/bash ubuntu;  \
    else \
        useradd -m -s /bin/bash ubuntu; \
    fi \
    && mkdir -p /home/ubuntu \
    && usermod -c 'Ubuntu MATE' ubuntu \
    && usermod -aG sudo ubuntu \
    && echo 'ubuntu:1122' | chpasswd \
    && chown -R ubuntu:ubuntu /home/ubuntu

# MATE session + XRDP configuration
RUN echo 'mate-session' > /home/ubuntu/.xsession \
    && chown ubuntu:ubuntu /home/ubuntu/.xsession \
    && printf '%s\n' \
       '#!/bin/sh' \
       'unset DBUS_SESSION_BUS_ADDRESS' \
       'unset XDG_RUNTIME_DIR' \
       'exec /usr/bin/mate-session' \
       > /etc/xrdp/startwm.sh \
    && chmod +x /etc/xrdp/startwm.sh \
    && if [ -f /etc/X11/Xwrapper.config ]; then \
         sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config; \
       else \
         printf '%s\n' 'allowed_users=anybody' 'needs_root_rights=yes' > /etc/X11/Xwrapper.config; \
       fi \
    && mkdir -p /home/ubuntu/.config \
    && cp /etc/mimeapps.list /home/ubuntu/.config/mimeapps.list \
    && chown -R ubuntu:ubuntu /home/ubuntu/.config

# Preconfigure Ubuntu MATE dark theme.
RUN mkdir -p /run/user/1000 \
    && chown ubuntu:ubuntu /run/user/1000 \
    && runuser -u ubuntu -- env XDG_RUNTIME_DIR=/run/user/1000 dbus-run-session -- sh -c '\
       gsettings set org.mate.interface gtk-theme "Yaru-MATE-dark" && \
       gsettings set org.mate.interface icon-theme "Yaru-MATE-dark" && \
       (gsettings set org.mate.interface color-scheme "prefers-dark" || true) && \
       gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/ubuntu-mate-noble/numbat_wallpaper_dark_3480x2160.jpg" && \
       gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/ubuntu-mate-noble/numbat_wallpaper_dark_3480x2160.jpg" && \
       gsettings set org.mate.background picture-filename "/usr/share/backgrounds/ubuntu-mate-noble/numbat_wallpaper_dark_3480x2160.jpg" && \
       gsettings set org.mate.background picture-options "zoom"'

# Disable services/components that are not useful inside a container.
RUN for f in mate-power-manager \
             ayatana-indicator-power \
             ayatana-indicator-printers \
             print-applet \
             update-notifier; do \
        if [ -f "/etc/xdg/autostart/$f.desktop" ]; then \
            mv "/etc/xdg/autostart/$f.desktop" "/etc/xdg/autostart/$f.desktop.disabled"; \
        fi; \
    done

# Apply available Ubuntu security/bug-fix updates at build time.
RUN apt-get update \
    && apt-get -y full-upgrade \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
