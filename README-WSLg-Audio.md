# Using WSLg for Audio in Docker Container

This guide explains how to use WSLg (Windows Subsystem for Linux GUI) as a sound device for your Kali Linux Docker container.

## Prerequisites

- Windows 11 with WSL2 installed
- WSLg enabled (included by default in recent Windows 11 versions)
- Docker Desktop for Windows configured to use the WSL2 backend

**Note:** You do NOT need to install PulseAudio on Windows. WSLg includes its own PulseAudio server that integrates with the Windows audio system automatically.

## How to Run the Container with WSLg Audio

1. **Build the Docker image**

   From within WSL2 (not from Windows PowerShell/CMD), navigate to the directory containing the Dockerfile and build the image:

   ```bash
   docker build -t kali-vnc-wslg .
   ```

2. **Run the container with WSLg socket mounted**

   The key is to mount the WSLg PulseAudio socket into the container:

   ```bash
   docker run -d --name kali-vnc \
     -p 5901:5901 \
     -v /mnt/wslg:/mnt/wslg \
     --security-opt apparmor=unconfined \
     kali-vnc-wslg
   ```

   The important parts are:
   - `-v /mnt/wslg:/mnt/wslg`: Mounts the WSLg directory containing the PulseAudio socket
   - `--security-opt apparmor=unconfined`: May be needed to access the socket

3. **Connect to the VNC server**

   Use a VNC client to connect to `localhost:5901` (password: `kalidev`)

## Testing Audio

Once connected to the VNC session, you can test audio with:

```bash
paplay /usr/share/sounds/alsa/Front_Center.wav
```

Or install a media player like VLC:

```bash
sudo apt update && sudo apt install -y vlc
```

## Troubleshooting

If audio doesn't work:

1. Verify WSLg is working by running a GUI app directly in WSL2
2. Check if the PulseAudio socket exists:
   ```bash
   ls -la /mnt/wslg/PulseServer
   ```
3. Inside the container, verify the PulseAudio connection:
   ```bash
   pactl info
   ```
4. Make sure you're running Docker from within WSL2, not from Windows directly

## Notes

- The container is configured to use the WSLg PulseAudio socket at `/mnt/wslg/PulseServer`
- This setup provides native audio support through Windows without additional configuration
- Audio quality and latency should be better than using network-based PulseAudio
