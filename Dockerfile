FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# 1) Stock Ubuntu MATE desktop (default wallpaper, default apps) + XRDP + Xorg
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
        ubuntu-mate-desktop \
        xrdp \
        xorg \
        dbus-x11 \
        sudo \
        curl \
        ca-certificates \
        openssl \
        x11-xserver-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 2) Real Firefox ESR browser.
#
#    On a normal PC, Ubuntu ships Firefox as a SNAP. Snap cannot run inside
#    a Docker/Railway container (no systemd), so anything that opens a
#    browser fails with "Failed to execute default Web Browser".
#    We install the official Mozilla Firefox ESR build instead and make it
#    the system default browser. (Verified working: 140.15.0esr)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://download.mozilla.org/?product=firefox-esr-latest&os=linux64&lang=en-US" -o /tmp/firefox.tar.xz \
    && tar xJf /tmp/firefox.tar.xz -C /opt \
    && rm -f /tmp/firefox.tar.xz \
    && printf '#!/bin/sh\nexec /opt/firefox/firefox "$@"\n' > /usr/bin/firefox-esr \
    && chmod 755 /usr/bin/firefox-esr \
    && printf '[Desktop Entry]\nName=Firefox Web Browser\nComment=Browse the Web\nExec=firefox-esr %%u\nTerminal=false\nIcon=/opt/firefox/browser/chrome/icons/default/default128.png\nType=Application\nCategories=Network;WebBrowser;\nMimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;\nStartupNotify=true\n' > /usr/share/applications/firefox-esr.desktop \
    && update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox-esr 100 \
    && update-alternatives --set x-www-browser /usr/bin/firefox-esr \
    && update-alternatives --install /usr/bin/www-browser www-browser /usr/bin/firefox-esr 100 \
    && update-alternatives --set www-browser /usr/bin/firefox-esr \
    && printf '[Default Applications]\nx-scheme-handler/http=firefox-esr.desktop\nx-scheme-handler/https=firefox-esr.desktop\ntext/html=firefox-esr.desktop\n' > /etc/mimeapps.list

# ---------------------------------------------------------------------------
# 3) RDP user: ubuntu / 1122 (default)
#    start.sh re-applies the password on every boot, so you can override it
#    at runtime with the RDP_PASSWORD Railway variable.
# ---------------------------------------------------------------------------
RUN useradd -m -s /bin/bash ubuntu && usermod -aG sudo ubuntu \
    && H=$(openssl passwd -6 -salt xrdp1122 1122) \
    && D=$(( $(date +%s) / 86400 )) \
    && grep -v '^ubuntu:' /etc/shadow > /tmp/sh.new \
    && echo "ubuntu:${H}:${D}:0:99999:7:::" >> /tmp/sh.new \
    && cat /tmp/sh.new > /etc/shadow && rm -f /tmp/sh.new

# ---------------------------------------------------------------------------
# 4) MATE session + Xorg-in-container configuration
# ---------------------------------------------------------------------------
RUN echo 'mate-session' > /home/ubuntu/.xsession \
    && chown ubuntu:ubuntu /home/ubuntu/.xsession \
    && printf '#!/bin/sh\nunset DBUS_SESSION_BUS_ADDRESS\nunset XDG_RUNTIME_DIR\nexec /usr/bin/mate-session\n' > /etc/xrdp/startwm.sh \
    && chmod +x /etc/xrdp/startwm.sh \
    && sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config \
    && mkdir -p /home/ubuntu/.config \
    && cp /etc/mimeapps.list /home/ubuntu/.config/mimeapps.list \
    && chown -R ubuntu:ubuntu /home/ubuntu/.config

# ---------------------------------------------------------------------------
# 4b) Dark theme (Yaru-MATE-dark) + dark stock Numbat wallpaper.
#     Written to the user's dconf database at build time, BEFORE the first
#     RDP session starts (the MATE settings-daemon owns the wallpaper key
#     once a session is running, so it must be preset).
# ---------------------------------------------------------------------------
RUN mkdir -p /run/user/1000 && chown ubuntu:ubuntu /run/user/1000 \
    && runuser -u ubuntu -- env XDG_RUNTIME_DIR=/run/user/1000 dbus-run-session -- sh -c '\
         gsettings set org.mate.interface gtk-theme "Yaru-MATE-dark" && \
         gsettings set org.mate.interface icon-theme "Yaru-MATE-dark" && \
         (gsettings set org.mate.interface color-scheme "prefers-dark" || true) && \
         gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/ubuntu-mate-noble/numbat_wallpaper_dark_3480x2160.jpg" && \
         gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/ubuntu-mate-noble/numbat_wallpaper_dark_3480x2160.jpg" && \
         gsettings set org.mate.background picture-filename "/usr/share/backgrounds/ubuntu-mate-noble/numbat_wallpaper_dark_3480x2160.jpg" && \
         gsettings set org.mate.background picture-options "zoom"'

# ---------------------------------------------------------------------------
# 5) Disable components that cannot work inside a container
#    (no power hardware, no CUPS, no update service) - they would otherwise
#    crash on login and show "Mate has experienced an internal error".
# ---------------------------------------------------------------------------
RUN for f in mate-power-manager \
             ayatana-indicator-power \
             ayatana-indicator-printers \
             print-applet \
             update-notifier; do \
        if [ -f "/etc/xdg/autostart/$f.desktop" ]; then \
            mv "/etc/xdg/autostart/$f.desktop" "/etc/xdg/autostart/$f.desktop.disabled"; \
        fi; \
    done

# ---------------------------------------------------------------------------
# 6) Keep everything fully updated & upgraded (incl. security updates)
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get -y full-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 7) Startup
# ---------------------------------------------------------------------------
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
