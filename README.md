# Kali Linux VNC Docker Container

This repository contains Docker configurations for running Kali Linux with a VNC server, allowing you to access a full Kali Linux desktop environment remotely.

## Two Approaches for Running the Container

There are two ways to run this container, depending on your environment:

1. **WSLg Approach** (Recommended for Windows 11 with WSL2)
2. **Windows PulseAudio Approach** (For running directly from Windows PowerShell/CMD)

## Recent Fixes

The following issues have been fixed in the latest version:

1. **DBus Connection Errors**: Fixed by properly mounting the DBus socket from the host
2. **MESA GL Version Override Errors**: Fixed by setting valid values for MESA environment variables

## Running with WSLg (Recommended)

This approach provides better performance, especially for audio. You must run Docker commands from within WSL2.

### Steps:

1. Open a WSL2 terminal
2. Navigate to the project directory:
   ```bash
   cd /mnt/c/projects/kali-vnc-docker
   ```
3. Run the provided script:
   ```bash
   ./run-kali-vnc-wslg.sh
   ```

This script will:
- Build the Docker image
- Run the container with proper mounts for WSLg and DBus
- Mount your C: drive to /windows/c in the container
- Expose port 5901 for VNC access

### Manual Command:

If you prefer to run the command manually:

```bash
docker build -t kali-vnc-wslg .

docker run -d --name kali-vnc \
  -p 5901:5901 \
  -v /mnt/wslg:/mnt/wslg \
  -v /run/dbus:/run/dbus \
  -v /mnt/c:/windows/c \
  --security-opt apparmor=unconfined \
  kali-vnc-wslg
```

## Running from Windows PowerShell/CMD

This approach allows you to run Docker commands directly from Windows.

### Steps:

1. Install PulseAudio on Windows (see Windows-Audio-Instructions.md)
2. Run the provided PowerShell script:
   ```powershell
   .\run-kali-vnc-windows.ps1
   ```

This script will:
- Build the Docker image using Dockerfile.windows
- Run the container with proper environment variables
- Mount your C: drive to /windows/c in the container
- Expose port 5901 for VNC access

### Manual Command:

If you prefer to run the command manually:

```powershell
docker build -t kali-vnc-windows -f Dockerfile.windows .

docker run -d --name kali-vnc `
  -p 5901:5901 `
  -v "C:\:/windows/c" `
  -e "MESA_GL_VERSION_OVERRIDE=4.5" `
  -e "MESA_GLSL_VERSION_OVERRIDE=450" `
  kali-vnc-windows
```

## Connecting to the VNC Server

Regardless of which approach you use:

1. Use a VNC client to connect to `localhost:5901`
2. Use the password: `kalidev`

## Troubleshooting

If you encounter issues:

1. **DBus Errors**: Make sure you're mounting the DBus socket correctly if using WSLg
2. **Audio Issues**: Follow the appropriate guide (WSLg-Docker-Instructions.md or Windows-Audio-Instructions.md)
3. **MESA GL Errors**: The Dockerfiles now set valid values for these variables, but you can also override them when running the container

For more detailed information, see the other documentation files in this repository.
