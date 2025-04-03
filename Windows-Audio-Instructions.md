# Using Docker with Audio from Windows PowerShell/CMD

This guide explains how to set up audio for your Kali Linux Docker container when running Docker commands directly from Windows PowerShell/CMD.

## Overview

Since you're running Docker commands from Windows PowerShell/CMD, we'll use a different approach than WSLg:

1. Install PulseAudio on Windows
2. Configure it to accept network connections
3. Use a Docker container that connects to this PulseAudio server

## Step 1: Install PulseAudio on Windows

1. Download the PulseAudio Windows binary from: https://www.freedesktop.org/wiki/Software/PulseAudio/Ports/Windows/Support/

   Alternatively, you can use the version from MSYS2:
   - Install MSYS2 from https://www.msys2.org/
   - Open MSYS2 and run: `pacman -S mingw-w64-x86_64-pulseaudio`

2. Extract the PulseAudio files to a location on your system (e.g., `C:\PulseAudio`)

## Step 2: Configure PulseAudio for Network Access

1. Create or edit the file `C:\PulseAudio\etc\pulse\default.pa` and add these lines:

   ```
   load-module module-native-protocol-tcp auth-anonymous=1
   load-module module-esound-protocol-tcp auth-anonymous=1
   load-module module-waveout sink_name=output source_name=input
   ```

2. Create or edit the file `C:\PulseAudio\etc\pulse\daemon.conf` and add:

   ```
   exit-idle-time = -1
   ```

## Step 3: Start PulseAudio Server

Create a batch file `start-pulseaudio.bat` with the following content:

```batch
@echo off
cd C:\PulseAudio\bin
pulseaudio.exe --exit-idle-time=-1 --load="module-native-protocol-tcp auth-anonymous=1" --load="module-esound-protocol-tcp auth-anonymous=1" --load="module-waveout sink_name=output source_name=input"
```

Run this batch file to start the PulseAudio server.

## Step 4: Build and Run the Docker Container

1. Build the Docker image using the Windows-compatible Dockerfile:

   ```
   docker build -t kali-vnc-windows -f Dockerfile.windows .
   ```

2. Run the Docker container:

   ```
   docker run -d --name kali-vnc -p 5901:5901 kali-vnc-windows
   ```

3. Connect to the VNC server using a VNC client at `localhost:5901` (password: `kalidev`)

## Mounting Windows Drives

If you want to access your Windows files from within the container, you can mount Windows drives or specific folders.

For detailed instructions and examples, see [Mount-Windows-Drives.md](Mount-Windows-Drives.md).

Example with C: drive mounted:

```powershell
docker run -d --name kali-vnc `
  -p 5901:5901 `
  -v "C:\:/windows/c" `
  kali-vnc-windows
```

## Testing Audio

Once connected to the VNC session, you can test audio with:

```bash
paplay /usr/share/sounds/alsa/Front_Center.wav
```

## Troubleshooting

If audio doesn't work:

1. Make sure PulseAudio is running on Windows
2. Check if PulseAudio is accepting connections:
   ```
   netstat -an | findstr 4713
   ```
3. Inside the container, verify the PulseAudio connection:
   ```
   pactl info
   ```
4. Try specifying your Windows IP address explicitly:
   ```
   docker run -d --name kali-vnc -p 5901:5901 -e PULSE_SERVER=tcp:192.168.1.x:4713 kali-vnc-windows
   ```
   (Replace 192.168.1.x with your actual Windows IP address)

## Notes

- This approach requires running PulseAudio on Windows, which is different from the WSLg approach
- The container is configured to connect to the Windows PulseAudio server via TCP
- If you prefer to use WSLg instead, follow the instructions in WSLg-Docker-Instructions.md
