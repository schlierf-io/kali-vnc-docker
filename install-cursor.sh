#!/bin/bash

# Create directory if it doesn't exist
mkdir -p /home/kalidev/.local/share

# Try different methods to download Cursor AI
download_cursor() {
    cd /home/kalidev/.local/share
    
    # Method 1: Try wget with specific version
    if wget --no-check-certificate https://github.com/getcursor/cursor/releases/download/v0.2.99/Cursor-0.2.99.AppImage -O cursor.AppImage; then
        echo "Successfully downloaded Cursor AI using wget"
        return 0
    fi
    
    # Method 2: Try curl with specific version
    if curl -Lk https://github.com/getcursor/cursor/releases/download/v0.2.99/Cursor-0.2.99.AppImage -o cursor.AppImage; then
        echo "Successfully downloaded Cursor AI using curl"
        return 0
    fi
    
    # Method 3: Try latest release with wget
    if wget --no-check-certificate https://github.com/getcursor/cursor/releases/latest/download/Cursor.AppImage -O cursor.AppImage; then
        echo "Successfully downloaded latest Cursor AI using wget"
        return 0
    fi
    
    # Method 4: Try latest release with curl
    if curl -Lk https://github.com/getcursor/cursor/releases/latest/download/Cursor.AppImage -o cursor.AppImage; then
        echo "Successfully downloaded latest Cursor AI using curl"
        return 0
    fi
    
    return 1
}

# Download Cursor icon
download_icon() {
    cd /home/kalidev/.local/share
    wget --no-check-certificate https://raw.githubusercontent.com/getcursor/cursor/main/packages/cursor/icons/cursor.png -O cursor.png || \
    curl -Lk https://raw.githubusercontent.com/getcursor/cursor/main/packages/cursor/icons/cursor.png -o cursor.png
}

# Main installation process
echo "Starting Cursor AI installation..."
update-ca-certificates

if download_cursor; then
    chmod +x /home/kalidev/.local/share/cursor.AppImage
    download_icon
    
    # Create desktop shortcut
    cp /home/kalidev/Desktop/cursor.desktop.template /home/kalidev/Desktop/cursor.desktop
    chmod +x /home/kalidev/Desktop/cursor.desktop
    
    # Set proper ownership
    chown -R kalidev:kalidev /home/kalidev/.local
    chown kalidev:kalidev /home/kalidev/Desktop/cursor.desktop
    
    echo "Cursor AI installation completed successfully"
else
    echo "Failed to download Cursor AI"
    exit 1
fi 