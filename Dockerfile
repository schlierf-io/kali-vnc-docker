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
    bash \
    bash-completion \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create kalidev user and add to sudo group
RUN useradd -m -s /bin/bash kalidev && \
    echo "kalidev:kalidev" | chpasswd && \
    adduser kalidev sudo && \
    echo "kalidev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up bash configuration for kalidev
RUN echo 'export PS1="\[\033[1;36m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "' >> /home/kalidev/.bashrc && \
    echo 'alias ll="ls -la"' >> /home/kalidev/.bashrc && \
    echo 'alias l="ls -l"' >> /home/kalidev/.bashrc && \
    echo 'source /etc/bash_completion' >> /home/kalidev/.bashrc && \
    chown kalidev:kalidev /home/kalidev/.bashrc

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

# Expose VNC port
EXPOSE 5901

# Switch to kalidev user
USER kalidev
WORKDIR /home/kalidev

# Start VNC server with dynamic scaling support
CMD ["sh", "-c", "vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes None -rfbport 5901 -localhost no --I-KNOW-THIS-IS-INSECURE -fg"]
