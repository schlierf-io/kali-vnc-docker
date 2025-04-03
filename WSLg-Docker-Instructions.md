# Running Docker with WSLg Audio from Windows

To use WSLg audio with your Docker container, you need to run the Docker command from within WSL2, not from Windows PowerShell/CMD. This is because the `/mnt/wslg` path is only available within the WSL2 environment.

## Step-by-Step Instructions

1. **Open a WSL2 terminal**

   You can do this in several ways:
   - Click the Start menu, search for "WSL", and open "Windows Subsystem for Linux"
   - Open PowerShell/CMD and type `wsl` to enter the WSL environment
   - Open Windows Terminal and select your WSL distribution from the dropdown

2. **Navigate to your project directory**

   Your project is located at `c:/projects/kali-vnc-docker` on Windows, which is accessible from WSL2 at `/mnt/c/projects/kali-vnc-docker`:

   ```bash
   cd /mnt/c/projects/kali-vnc-docker
   ```

3. **Build the Docker image**

   ```bash
   docker build -t kali-vnc-wslg .
   ```

4. **Run the Docker container**

   ```bash
   docker run -d --name kali-vnc \
     -p 5901:5901 \
     -v /mnt/wslg:/mnt/wslg \
     -v /mnt/c:/windows/c \
      --security-opt apparmor=unconfined \
     kali-vnc-wslg
   ```

5. **Connect to the VNC server**

   Use a VNC client to connect to `localhost:5901` (password: `kalidev`)

## Mounting Windows Drives

If you want to access your Windows files from within the container, you can mount Windows drives or specific folders.

For detailed instructions and examples, see [Mount-Windows-Drives.md](Mount-Windows-Drives.md).

Example with C: drive mounted:

```bash
docker run -d --name kali-vnc \
  -p 5901:5901 \
  -v /mnt/wslg:/mnt/wslg \
  -v /mnt/c:/windows/c \
  --security-opt apparmor=unconfined \
  kali-vnc-wslg
```

## Why This Works

- Docker Desktop for Windows with WSL2 backend allows running Docker commands from both Windows and WSL2
- However, to access WSLg features (like the PulseAudio socket), you must run the command from within WSL2
- The `-v /mnt/wslg:/mnt/wslg` option mounts the WSLg directory into the container, which is only possible from WSL2

## Troubleshooting

If you get an error like `Error response from daemon: invalid mount config for type "bind": source path "/mnt/wslg" does not exist`, it confirms you're running the command from Windows instead of WSL2.

## Alternative: Running from Windows

If you prefer to run Docker commands from Windows, you would need a different approach that doesn't use WSLg. The original approach in your Dockerfile (using TCP to connect to a PulseAudio server on the host) would be more appropriate for that scenario.
