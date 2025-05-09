#!/bin/bash

# Build the Docker image
docker build -t kali-vnc-wslg .

# Run the Docker container with proper mounts
docker run -d --name kali-vnc \
  -p 5901:5901 \
  -v /mnt/wslg:/mnt/wslg \
  -v /run/dbus:/run/dbus \
  -v /mnt/c:/windows/c \
  --security-opt apparmor=unconfined \
  --gpus all \
  kali-vnc-wslg

echo "Container started. Connect to VNC at localhost:5901 (password: kalidev)"

export PULSE_LATENCY_MSEC=50
