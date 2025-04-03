# Mounting Windows Drives in Docker Container

This guide explains how to mount Windows drives into your Kali Linux Docker container, allowing you to access your Windows files from within the container.

## Option 1: When Running Docker from WSL2

When running Docker from within WSL2 (as described in WSLg-Docker-Instructions.md), Windows drives are already mounted in WSL2 at `/mnt/c`, `/mnt/d`, etc. You can pass these through to your Docker container.

### Example: Mounting C: Drive

```bash
docker run -d --name kali-vnc \
  -p 5901:5901 \
  -v /mnt/wslg:/mnt/wslg \
  -v /mnt/c:/windows/c \
  --security-opt apparmor=unconfined \
  kali-vnc-wslg
```

This mounts your Windows C: drive to `/windows/c` inside the container.

### Example: Mounting Multiple Drives

```bash
docker run -d --name kali-vnc \
  -p 5901:5901 \
  -v /mnt/wslg:/mnt/wslg \
  -v /mnt/c:/windows/c \
  -v /mnt/d:/windows/d \
  -v /mnt/e:/windows/e \
  --security-opt apparmor=unconfined \
  kali-vnc-wslg
```

### Example: Mounting Specific Folders

You can also mount specific folders instead of entire drives:

```bash
docker run -d --name kali-vnc \
  -p 5901:5901 \
  -v /mnt/wslg:/mnt/wslg \
  -v "/mnt/c/Users/YourUsername/Documents:/home/kalidev/Documents" \
  -v "/mnt/c/Projects:/home/kalidev/Projects" \
  --security-opt apparmor=unconfined \
  kali-vnc-wslg
```

## Option 2: When Running Docker from Windows PowerShell/CMD

When running Docker directly from Windows PowerShell/CMD (as described in Windows-Audio-Instructions.md), you can use the standard Docker volume syntax with Windows paths.

### Example: Mounting C: Drive

```powershell
docker run -d --name kali-vnc `
  -p 5901:5901 `
  -v "C:\:/windows/c" `
  kali-vnc-windows
```

Note the backtick (`) for line continuation in PowerShell. For CMD, use caret (^) instead.

### Example: Mounting Multiple Drives

```powershell
docker run -d --name kali-vnc `
  -p 5901:5901 `
  -v "C:\:/windows/c" `
  -v "D:\:/windows/d" `
  -v "E:\:/windows/e" `
  kali-vnc-windows
```

### Example: Mounting Specific Folders

```powershell
docker run -d --name kali-vnc `
  -p 5901:5901 `
  -v "C:\Users\YourUsername\Documents:/home/kalidev/Documents" `
  -v "C:\Projects:/home/kalidev/Projects" `
  kali-vnc-windows
```

## Accessing Mounted Drives Inside the Container

Once connected to the container via VNC, you can access the mounted drives at the specified paths. For example, if you mounted C: drive to `/windows/c`, you can access it by:

1. Opening a terminal in the VNC session
2. Navigating to the mount point: `cd /windows/c`
3. Using file manager (Thunar in Xfce) to browse to `/windows/c`

## Permissions and Ownership

You might encounter permission issues when accessing Windows files from Linux. To address this:

1. Inside the container, you can use `sudo` to access files with elevated privileges
2. For persistent access, you can change ownership of mounted directories:
   ```bash
   sudo chown -R kalidev:kalidev /windows/c/some/directory
   ```

## Performance Considerations

- Accessing files on mounted Windows drives will be slower than accessing files stored directly in the container
- For best performance with large files or I/O-intensive operations, consider copying files to the container's filesystem first

## Troubleshooting

If you encounter issues with mounted drives:

1. Verify the mount was successful:
   ```bash
   ls -la /windows/c
   ```

2. Check for permission issues:
   ```bash
   ls -la /windows/c | grep "Permission denied"
   ```

3. For WSL2, ensure the path exists in WSL2 before mounting:
   ```bash
   ls -la /mnt/c
   ```

4. For Windows PowerShell/CMD, try using absolute paths with proper escaping
