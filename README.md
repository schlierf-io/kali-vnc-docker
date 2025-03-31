# Kali Linux VNC Docker Container

This Docker container provides a Kali Linux environment with XFCE desktop accessible via VNC, featuring NVIDIA GPU support and development tools.

## Features

- Kali Linux (Rolling Release)
- XFCE Desktop Environment
- TigerVNC Server
- NVIDIA GPU Support with CUDA
- Development Tools:
  - Node.js 20.x with npm, yarn, and pnpm
  - Java 21 (Temurin) with Maven and Gradle
  - Cursor AI IDE
  - Git with Oh My Zsh
- Audio Support via PulseAudio
- Default user: `kalidev` with sudo access
- Dynamic display scaling

## Prerequisites

- Docker with NVIDIA Container Toolkit installed
- NVIDIA GPU with compatible drivers
- VNC Viewer
- PulseAudio (for audio support on Windows)

## Quick Start

1. Build the container:
```bash
docker build -t kali-vnc .
```

2. Run the container with GPU support:
```bash
docker run -d --gpus all -p 5901:5901 -p 4713:4713 --name kali-vnc-dev kali-vnc
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

## Development Environment

### Node.js Development
- Node.js 20.x with npm
- Global package managers:
  - yarn
  - pnpm

### Java Development
- Java 21.0.6-tem (Temurin)
- Build tools:
  - Maven 3.9.9
  - Gradle 8.13

### Shell Environment
- ZSH with Oh My Zsh
- Theme: robbyrussell
- Git integration
- Custom aliases and configurations

## Audio Configuration

1. Install PulseAudio on Windows host
2. Configure PulseAudio to accept network connections
3. Container automatically connects to host PulseAudio server

## NVIDIA GPU Support

The container includes:
- NVIDIA Container Toolkit
- NVIDIA drivers
- CUDA Toolkit
- NVIDIA Settings
- X11 configuration for GPU acceleration

To verify GPU support inside the container:
```bash
nvidia-smi  # Check GPU status
glxinfo | grep "OpenGL renderer"  # Check OpenGL renderer
```

## VNC Client Settings

For optimal performance with TigerVNC Viewer:
- Picture Quality: High
- Enable "Auto Scaling"
- Compression Level: High
- JPEG Quality: High
- Enable "Use JPEG compression"
- Color Level: Full (24-bit)

## Security Note

This container is configured without VNC encryption for development purposes. For production use, consider:
- Enabling VNC encryption
- Using SSH tunneling
- Implementing additional security measures
- Restricting port access

## License

MIT License 