FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    qemu qemu-kvm qemu-utils qemu-system-x86 \
    curl wget unzip git net-tools \
    python3 python3-pip \
    novnc websockify \
    xfce4 xfce4-goodies tightvncserver \
    locales \
    --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up Indian English locale
RUN locale-gen en_IN.UTF-8
ENV LANG=en_IN.UTF-8 \
    LANGUAGE=en_IN:en \
    LC_ALL=en_IN.UTF-8

# Clone noVNC and websockify
WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git && \
    git clone https://github.com/novnc/websockify.git noVNC/utils/websockify

# Set up VNC password
RUN mkdir -p /root/.vnc && \
    echo "vncpass" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Create workspace for running OS ISOs
WORKDIR /os-exploration
VOLUME ["/os-images"]

# Expose ports for noVNC and VNC
EXPOSE 5901 6080

# Launch VNC server and noVNC proxy on startup
CMD bash -c "\
    export DISPLAY=:1 && \
    vncserver :1 -geometry 1280x800 -depth 24 && \
    /opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080"
