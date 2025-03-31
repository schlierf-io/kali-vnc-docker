# Kali Linux VNC Docker Container

A feature-rich Kali Linux container with VNC, development tools, and NVIDIA GPU support.

## Features

- Kali Linux desktop environment (XFCE)
- VNC server for remote access
- NVIDIA GPU support with CUDA toolkit
- Development Tools:
  - Node.js and npm (with global packages: yarn, pnpm)
  - Java Development Kit (via SDKMAN!)
  - Sublime Text 4
  - JetBrains Toolbox
  - Cursor AI IDE (via AppMan)
  - Git and development essentials
- ZSH with Oh My Zsh (theme: robbyrussell)
- Audio support via PulseAudio
- AppMan package manager for easy software installation

## Prerequisites

- Docker installed and running
- NVIDIA GPU with appropriate drivers (for GPU support)
- NVIDIA Container Toolkit installed
- VNC client installed on your system

## Quick Start

1. Build the container:
```bash
docker build -t kali-vnc .
```

2. Run the container with GPU support:
```bash
docker run -d --name kali-vnc-dev --gpus all -p 5901:5901 -p 4713:4713 --shm-size 1g kali-vnc
```

3. Connect using a VNC client:
   - Host: localhost or 127.0.0.1
   - Port: 5901
   - Password: kalidev

## User Credentials

- Username: kalidev
- Password: kalidev

## Development Environment

### Text Editors and IDEs
- **Sublime Text 4**: Modern text editor with extensive plugin support
- **Cursor AI**: AI-powered IDE for enhanced development
- **JetBrains Toolbox**: Install and manage JetBrains IDEs

### Package Management
- **AppMan**: Rootless package manager for easy software installation
  - Install new applications: `appman -i <package-name>`
  - List installed applications: `appman -l`
  - Update all applications: `appman -u`
  - For AppImages in Docker: `appman -i --appimage-extract-and-run <package-name>`
    - This flag is required for applications like Cursor due to FUSE limitations in containers
    - Extracts and runs AppImages without requiring FUSE support

### Node.js Environment
- Global packages pre-installed:
  - yarn
  - pnpm

### Java Development
- SDKMAN! installed for Java version management
- Access via: `source "$HOME/.sdkman/bin/sdkman-init.sh"`

## Audio Configuration

Audio is supported through PulseAudio. For Windows hosts:

1. Download and install PulseAudio for Windows:
   - Download from: http://www.freedesktop.org/software/pulseaudio/misc/pulseaudio-1.1.zip
   - Extract to `C:\Program Files\PulseAudio`
   - Add `C:\Program Files\PulseAudio\bin` to your system PATH

2. Create the PulseAudio configuration:
   - Create directory: `%APPDATA%\pulse`
   - Create two files:
     
     a. `%APPDATA%\pulse\daemon.conf`:
     ```conf
     exit-idle-time = -1
     ```

     b. `%APPDATA%\pulse\default.pa`:
     ```conf
     load-module module-native-protocol-tcp auth-anonymous=1
     load-module module-esound-protocol-tcp auth-anonymous=1
     load-module module-waveout
     ```

3. Start PulseAudio on Windows:
   ```powershell
   # Run in PowerShell as Administrator
   cd "C:\Program Files\PulseAudio\bin"
   .\pulseaudio.exe --start
   ```

4. Verify PulseAudio is running:
   ```powershell
   Get-Process pulseaudio
   ```

The container will automatically connect to the host's PulseAudio server on port 4713.

## NVIDIA GPU Support

The container includes full NVIDIA GPU support with:
- NVIDIA Container Toolkit
- NVIDIA drivers
- CUDA toolkit
- VA-API configuration for hardware acceleration

To verify GPU support inside the container:
```bash
nvidia-smi
```

## VNC Client Settings

For optimal performance:
- Color depth: 24-bit
- Encoding: Tight
- Quality: High (when available)
- Enable clipboard sharing

## Security Notes

1. VNC connection is not encrypted by default. For production use:
   - Use SSH tunneling
   - Set up VPN
   - Change default passwords

2. Container security:
   - Runs as non-root user (kalidev)
   - Limited system access
   - Isolated environment

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 