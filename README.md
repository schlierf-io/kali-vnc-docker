# Kali Linux VNC Docker Container

This Docker container provides a Kali Linux environment with XFCE desktop accessible via VNC.

## Features

- Kali Linux (Rolling Release)
- XFCE Desktop Environment
- TigerVNC Server
- Default user: `kalidev` with sudo access
- Dynamic display scaling
- Software rendering for better compatibility

## Quick Start

1. Build the container:
```bash
docker build -t kali-vnc .
```

2. Run the container:
```bash
docker run -d -p 5901:5901 --name kali-vnc kali-vnc
```

3. Connect using any VNC client:
   - Address: `localhost:5901` or `127.0.0.1:5901`
   - No VNC password required (SecurityTypes None)
   - Color Depth: 24-bit
   - Resolution: 1920x1080

## User Credentials

- Username: `kalidev`
- Password: `kalidev`
- Sudo access: Yes (no password required)

## VNC Client Settings

For optimal performance with TigerVNC Viewer:
- Picture Quality: High
- Enable "Auto Scaling"
- Compression Level: High
- JPEG Quality: High
- Enable "Use JPEG compression"
- Color Level: Full (24-bit)

## Security Note

This container is configured without VNC encryption for development purposes. For production use, consider enabling VNC encryption and implementing additional security measures.

## License

MIT License 