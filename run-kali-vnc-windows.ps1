Write-Host "Building Docker image..."
docker build -t kali-vnc-windows -f Dockerfile.windows .

Write-Host "Running Docker container..."
docker run -d --name kali-vnc `
  -p 5901:5901 `
  -v "C:\:/windows/c" `
  -e "MESA_GL_VERSION_OVERRIDE=4.5" `
  -e "MESA_GLSL_VERSION_OVERRIDE=450" `
  kali-vnc-windows

Write-Host "Container started. Connect to VNC at localhost:5901 (password: kalidev)"
