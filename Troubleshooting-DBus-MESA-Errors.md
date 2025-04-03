# Troubleshooting DBus and MESA GL Errors

This guide addresses common DBus and MESA GL errors that may occur when running the Kali Linux VNC Docker container.

## Common Error Messages

### DBus Errors

```
Failed to connect to the bus: Failed to connect to socket /run/dbus/system_bus_socket: No such file or directory
```

### MESA GL Errors

```
error: invalid value for MESA_GL_VERSION_OVERRIDE
error: invalid value for MESA_GLSL_VERSION_OVERRIDE
```

## Causes and Solutions

### DBus Errors

**Cause**: The container cannot access the host's DBus system socket, which is required for certain system services and GUI applications.

**Solutions**:

1. **When running from WSL2** (Recommended):
   - Mount the host's DBus socket into the container:
   ```bash
   docker run -d --name kali-vnc \
     -p 5901:5901 \
     -v /mnt/wslg:/mnt/wslg \
     -v /run/dbus:/run/dbus \
     -v /mnt/c:/windows/c \
     --security-opt apparmor=unconfined \
     kali-vnc-wslg
   ```

2. **When running from Windows PowerShell/CMD**:
   - This is more challenging as Windows doesn't have a native DBus socket.
   - Some applications may not work properly without DBus.
   - Consider using the WSL2 approach instead.

### MESA GL Errors

**Cause**: The MESA environment variables are either unset or set to invalid values. These variables control OpenGL version compatibility and shader language versions.

**Solutions**:

1. **Using the updated Dockerfiles**:
   - The Dockerfiles have been updated to set valid values for these variables:
   ```
   ENV LIBGL_ALWAYS_SOFTWARE=0
   ENV GALLIUM_DRIVER=llvmpipe
   ENV MESA_GL_VERSION_OVERRIDE=4.5
   ENV MESA_GLSL_VERSION_OVERRIDE=450
   ENV MESA_LOADER_DRIVER_OVERRIDE=iris
   ```

2. **Override at runtime**:
   - You can also override these values when running the container:
   ```bash
   docker run -d --name kali-vnc \
     -p 5901:5901 \
     -e "MESA_GL_VERSION_OVERRIDE=4.5" \
     -e "MESA_GLSL_VERSION_OVERRIDE=450" \
     ... other options ...
     kali-vnc-wslg
   ```

## Testing the Fixes

After applying the fixes, you can test if they resolved the issues:

### Testing DBus

Inside the container, run:

```bash
dbus-send --system --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames
```

If successful, you should see a list of available DBus services.

### Testing MESA GL

Inside the container, run:

```bash
glxinfo | grep "OpenGL version"
```

This should show the OpenGL version without any errors.

## Additional Troubleshooting

If you continue to experience issues:

1. **Check if DBus is running on the host**:
   ```bash
   systemctl status dbus
   ```

2. **Verify the DBus socket exists**:
   ```bash
   ls -la /run/dbus/system_bus_socket
   ```

3. **Check MESA environment variables inside the container**:
   ```bash
   env | grep MESA
   ```

4. **Try running with software rendering forced**:
   ```bash
   docker run -d --name kali-vnc \
     -p 5901:5901 \
     -e "LIBGL_ALWAYS_SOFTWARE=1" \
     ... other options ...
     kali-vnc-wslg
   ```

## When to Use Each Approach

- **WSLg Approach**: Preferred for Windows 11 users with WSL2. Provides better integration with the host system, including DBus and audio.
- **Windows PowerShell/CMD Approach**: Use only if you cannot use WSL2 for some reason. May have limitations with DBus functionality.
