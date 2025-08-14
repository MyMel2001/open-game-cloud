FROM nvidia/cuda:13.0.0-tensorrt-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=gamer \
    UID=1000 \
    GID=1000 \
    DISPLAY=:0

# Install core packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies \
    dbus-x11 x11-xserver-utils x11-utils \
    mesa-utils pulseaudio alsa-utils \
    wget curl git unzip \
    flatpak software-properties-common \
    sudo nano ca-certificates gnupg \
    # VNC + noVNC
    novnc websockify x11vnc \
    # X server for VNC
    xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Sunshine
RUN mkdir -p /opt/sunshine && \
    wget -qO /tmp/sunshine.tar.gz https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-linux-x86_64.tar.gz && \
    tar -xvf /tmp/sunshine.tar.gz -C /opt/sunshine && \
    rm /tmp/sunshine.tar.gz && \
    chmod +x /opt/sunshine/sunshine

# Create non-root user
RUN groupadd -g ${GID} ${USERNAME} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} && \
    usermod -aG audio,video,input ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Enable Flatpak remote
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Sunshine default config dir
RUN mkdir -p ~/.config/sunshine

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 8081 47984 47989 48010 5900

ENTRYPOINT ["/entrypoint.sh"]
