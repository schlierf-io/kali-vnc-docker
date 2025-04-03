FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    kali-desktop-xfce \
    tigervnc-standalone-server \
    tigervnc-common \
    dbus-x11 \
    xfce4-terminal \
    sudo \
    x11-xserver-utils \
    xvfb \
    mesa-utils \
    libgl1-mesa-dri \
    libglu1 \
    libosmesa6 \
    libglx-mesa0 \
    libgl1 \
    libegl1 \
    libva2 \
    libva-drm2 \
    libva-x11-2 \
    vainfo \
    vdpau-driver-all \
    libvdpau1 \
    bash \
    bash-completion \
    curl \
    wget \
    gnupg \
    git \
    zip \
    unzip \
    ca-certificates \
    pulseaudio \
    pavucontrol \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Sublime Text
RUN curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublime-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/sublime-keyring.gpg] https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list && \
    apt-get update && \
    apt-get install -y sublime-text && \
    rm -rf /var/lib/apt/lists/*

# Configure VA-API for NVIDIA
RUN mkdir -p /etc/nvidia-vaapi-driver && \
    echo "driver_path=/usr/lib/x86_64-linux-gnu/dri/nvidia_drv_video.so" > /etc/nvidia-vaapi-driver/nvidia-vaapi-driver.conf

# Set VA-API environment variables
ENV LIBVA_DRIVER_NAME=nvidia
ENV LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri

# Create kalidev user and add to sudo group
RUN useradd -m -s /bin/bash kalidev && \
    echo "kalidev:kalidev" | chpasswd && \
    adduser kalidev sudo && \
    echo "kalidev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/lib/node_modules && \
    chown -R kalidev:kalidev /usr/local/lib/node_modules

# Add NVIDIA repository and install NVIDIA packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 \
    curl \
    wget \
    git \
    ca-certificates \
    coreutils \
    grep \
    sed \
    binutils \
    less \
    nano \
    unzip \
    tar \
    torsocks \
    zsync && \
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
    curl -s -L https://nvidia.github.io/libnvidia-container/debian10/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nvidia-container-toolkit \
    nvidia-driver \
    nvidia-cuda-toolkit \
    nvidia-settings \
    nvidia-xconfig \
    libva2 \
    libva-drm2 \
    libva-x11-2 \
    vainfo \
    vdpau-driver-all \
    libvdpau1 && \
    rm -rf /var/lib/apt/lists/*

# Create required directories for AppMan and install it
RUN mkdir -p /home/kalidev/.local/bin && \
    mkdir -p /home/kalidev/.config/appman && \
    mkdir -p /home/kalidev/.cache/appman && \
    mkdir -p /home/kalidev/.local/share/AM && \
    mkdir -p /home/kalidev/Applications && \
    chown -R kalidev:kalidev /home/kalidev/.local && \
    chown -R kalidev:kalidev /home/kalidev/.config && \
    chown -R kalidev:kalidev /home/kalidev/.cache && \
    chown -R kalidev:kalidev /home/kalidev/Applications && \
    su - kalidev -c 'wget -q https://raw.githubusercontent.com/ivan-hc/AM/main/AM-INSTALLER && \
    chmod a+x ./AM-INSTALLER && \
    echo "2" | ./AM-INSTALLER && \
    rm ./AM-INSTALLER'

# Switch to kalidev user for AppMan configuration
USER kalidev
ENV PATH=/home/kalidev/.local/bin:${PATH}
RUN echo "/home/kalidev/Applications" | appman && \
    appman -i --appimage-extract-and-run cursor

# Switch back to root for remaining installations
USER root

# Install JetBrains Toolbox
RUN mkdir -p /opt/jetbrains-toolbox \
    && wget -qO /tmp/jetbrains-toolbox.tar.gz "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.2.1.19765.tar.gz" \
    && tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/jetbrains-toolbox --strip-components=1 \
    && rm /tmp/jetbrains-toolbox.tar.gz \
    && chmod +x /opt/jetbrains-toolbox/jetbrains-toolbox \
    && ln -s /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox

# Configure NVIDIA Container Runtime
RUN nvidia-ctk runtime configure --runtime=docker

# Set NVIDIA environment variables
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# Set software rendering environment variables with valid values
ENV LIBGL_ALWAYS_SOFTWARE=0
ENV GALLIUM_DRIVER=llvmpipe
ENV MESA_GL_VERSION_OVERRIDE=4.5
ENV MESA_GLSL_VERSION_OVERRIDE=450
ENV MESA_LOADER_DRIVER_OVERRIDE=iris

# Add NVIDIA paths
ENV PATH=/usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/nvidia/lib:${LD_LIBRARY_PATH:-}

# Switch to kalidev user for npm global installations
USER kalidev
ENV NPM_CONFIG_PREFIX=/home/kalidev/.npm-global
ENV PATH=/home/kalidev/.npm-global/bin:${PATH}
RUN mkdir -p /home/kalidev/.npm-global && \
    npm config set prefix '/home/kalidev/.npm-global' && \
    echo 'export NPM_CONFIG_PREFIX=/home/kalidev/.npm-global' >> /home/kalidev/.bashrc && \
    echo 'export PATH="/home/kalidev/.npm-global/bin:$PATH"' >> /home/kalidev/.bashrc && \
    npm install -g yarn && \
    npm install -g pnpm

# Install SDKMAN! for kalidev user
RUN bash -c "curl -s 'https://get.sdkman.io' | bash" && \
    echo 'source "/home/kalidev/.sdkman/bin/sdkman-init.sh"' >> /home/kalidev/.bashrc && \
    bash -c 'source "/home/kalidev/.sdkman/bin/sdkman-init.sh" && \
    export SDKMAN_DIR="/home/kalidev/.sdkman" && \
    [[ -s "/home/kalidev/.sdkman/bin/sdkman-init.sh" ]] && \
    source "/home/kalidev/.sdkman/bin/sdkman-init.sh" && \
    sdk install java 21.0.6-tem && \
    sdk install maven 3.9.9 && \
    sdk install gradle 8.13'

USER root

# Create VNC configuration directory and set up X11 for kalidev
RUN mkdir -p /home/kalidev/.config/tigervnc && \
    echo "kalidev" | vncpasswd -f > /home/kalidev/.config/tigervnc/passwd && \
    chmod 600 /home/kalidev/.config/tigervnc/passwd && \
    touch /home/kalidev/.Xauthority && \
    chmod 600 /home/kalidev/.Xauthority && \
    touch /home/kalidev/.Xresources && \
    chmod 644 /home/kalidev/.Xresources && \
    chown -R kalidev:kalidev /home/kalidev/

# Configure VNC server with Xfce and enable proper scaling
RUN echo '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
export LIBGL_ALWAYS_SOFTWARE=1\n\
export XKL_XMODMAP_DISABLE=1\n\
export XDG_CURRENT_DESKTOP="XFCE"\n\
export XDG_MENU_PREFIX="xfce-"\n\
# Do not start PulseAudio daemon as we use WSLg socket\n\
xrdb $HOME/.Xresources\n\
xsetroot -solid grey\n\
/usr/bin/startxfce4 --replace > /dev/null 2>&1 &\n\
sleep 2\n\
xrandr --output VNC-0 --mode 1920x1080\n\
while true; do\n\
    sleep 1\n\
done' > /home/kalidev/.config/tigervnc/xstartup && \
    chmod +x /home/kalidev/.config/tigervnc/xstartup && \
    chown kalidev:kalidev /home/kalidev/.config/tigervnc/xstartup

# Configure PulseAudio to use WSLg
RUN mkdir -p /home/kalidev/.config/pulse && \
    mkdir -p /run/pulse && \
    chown -R kalidev:kalidev /run/pulse && \
    echo "# Use WSLg PulseAudio socket\n\
    default-server = unix:/mnt/wslg/PulseServer\n\
    # Performance optimizations\n\
    autospawn = no\n\
    daemon-binary = /bin/true\n\
    enable-shm = false\n\
    # Low-latency settings\n\
    default-fragments = 8\n\
    default-fragment-size-msec = 5\n\
    # High-quality audio\n\
    default-sample-format = s24le\n\
    default-sample-rate = 48000\n\
    avoid-resampling = true\n\
    resample-method = speex-float-3" > /home/kalidev/.config/pulse/client.conf && \
    chown -R kalidev:kalidev /home/kalidev/.config/pulse

# Expose VNC and PulseAudio ports
EXPOSE 5901 4713

# Switch to kalidev user
USER kalidev
WORKDIR /home/kalidev

# Start VNC server with dynamic scaling support
CMD ["sh", "-c", "vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes None -rfbport 5901 -localhost no --I-KNOW-THIS-IS-INSECURE -fg"]

# Set environment variables for WSLg audio
ENV PULSE_SERVER=unix:/mnt/wslg/PulseServer
ENV PULSE_LATENCY_MSEC=20
ENV PULSE_PROP="filter.want=echo-cancel"

# Set software rendering environment variables with valid values
ENV LIBGL_ALWAYS_SOFTWARE=0
ENV GALLIUM_DRIVER=llvmpipe
ENV MESA_GL_VERSION_OVERRIDE=4.5
ENV MESA_GLSL_VERSION_OVERRIDE=450
ENV MESA_LOADER_DRIVER_OVERRIDE=iris

# Add NVIDIA paths
ENV PATH=/usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/nvidia/lib:${LD_LIBRARY_PATH:-}
