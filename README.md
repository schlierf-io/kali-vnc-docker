# Kali Linux Development Environment

A customized Kali Linux container with XFCE desktop, development tools, and audio/video support.

## Prerequisites

- Docker Desktop for Windows
- NVIDIA GPU with updated drivers
- NVIDIA Container Toolkit
- VNC Viewer
- MSYS2 (for audio support)

## Quick Start

1. **Clone and Build**:

   ```powershell
   git clone https://github.com/yourusername/kali-dev1.git
   cd kali-dev1
   docker build -t kalidev .
   ```

2. **Setup Audio (Windows Host)**:

   ```bash
   # Install PulseAudio in MinGW64
   pacman -S mingw-w64-x86_64-pulseaudio

   # Configure PulseAudio
   mkdir -p ~/.config/pulse
   echo "default-server = 127.0.0.1
   autospawn = yes
   daemon-binary = /mingw64/bin/pulseaudio.exe
   enable-shm = false" > ~/.config/pulse/client.conf

   echo ".include /etc/pulse/default.pa
   exit-idle-time = -1
   daemonize = no
   load-default-script-file = yes" > ~/.config/pulse/daemon.conf

   # Create default.pa for module loading
   mkdir -p ~/.config/pulse/default.pa.d
   echo "load-module module-native-protocol-tcp
   auth-anonymous=1 listen=0.0.0.0
   load-module module-waveout" > ~/.config/pulse/default.pa.d/default.pa

   # Start PulseAudio
   taskkill /F /IM pulseaudio.exe 2>/dev/null
   /mingw64/bin/pulseaudio.exe --exit-idle-time=-1 --verbose

   ```

3. **Run Container**:

   ```powershell
   docker run -d `
     --name kalidev `
     --gpus all `
     -p 5901:5901 `
     -p 4713:4713 `
     --add-host=host.docker.internal:host-gateway `
     -e PULSE_SERVER=tcp:host.docker.internal:4713 `
     -e PULSE_COOKIE= `
     --shm-size=2g `
     kalidev
   ```

4. **Connect**:
   - VNC: `localhost:5901` (no password)
   - Terminal: `docker exec -it kalidev bash`

## Features

### Development Tools

- Node.js 20.x (with npm, yarn, pnpm)
- Java 21 (via SDKMAN)
- Maven 3.9.9 and Gradle 8.13
- Git and Sublime Text
- JetBrains Toolbox
- Cursor IDE

### System

- Kali Linux with XFCE desktop
- VNC server for remote access
- PulseAudio for audio support
- NVIDIA GPU acceleration
- Shared memory optimization

## Troubleshooting

### Audio Issues

```bash
# Check PulseAudio status
/mingw64/bin/pulseaudio.exe --check

# Reset configuration if needed
rm -rf ~/.config/pulse/*
rm -rf /c/msys64/mingw64/etc/pulse/default.pa.d/*

# Restart with debug output
/mingw64/bin/pulseaudio.exe -k
/mingw64/bin/pulseaudio.exe --start --verbose --log-level=debug

# Test in container
docker exec -it kalidev pactl info
```

### Container Issues

```powershell
# View logs
docker logs kalidev

# Quick restart
docker restart kalidev

# Full rebuild
docker stop kalidev
docker rm kalidev
docker rmi kalidev
docker build -t kalidev .
```

## Configuration

### Default Credentials

- Username: `kalidev`
- Password: `kalidev`
- sudo: Yes (no password)

### Environment Variables

- `PULSE_SERVER`: tcp:host.docker.internal:4713
- `PULSE_COOKIE`: (empty for anonymous auth)
- `NVIDIA_VISIBLE_DEVICES`: all
- `NVIDIA_DRIVER_CAPABILITIES`: all

## Contributing

Issues and enhancement requests are welcome! Please check existing issues before submitting new ones.
