FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=gamer \
    UID=1000 \
    GID=1000

# Install base packages, NVIDIA support, desktop, Flatpak, PulseAudio, Sunshine deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies \
    dbus-x11 x11-xserver-utils x11-utils \
    mesa-utils pulseaudio alsa-utils \
    wget curl git unzip \
    flatpak software-properties-common \
    sudo nano \
    ca-certificates gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# NVIDIA container toolkit (host must have NVIDIA drivers installed)
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/noble/libnvidia-container.list \
        | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#' \
        > /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
    apt-get update && \
    apt-get install -y nvidia-container-toolkit && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

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

ENTRYPOINT ["/entrypoint.sh"]
