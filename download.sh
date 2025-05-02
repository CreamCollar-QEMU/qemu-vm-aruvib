#!/bin/bash

# Create directories for OS images
mkdir -p os_images/linux
mkdir -p os_images/bsd
mkdir -p os_images/windows
mkdir -p os_images/misc

# Log function that records both to screen and to the command log
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"
    # The command will already be recorded by the PROMPT_COMMAND mechanism
}

# Function to download with progress and verification
download_file() {
    local url=$1
    local output=$2
    local description=$3
    
    log "Downloading $description from $url"
    
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$output")"
    
    # Download the file
    wget --progress=bar:force -O "$output" "$url"
    
    # Verify download was successful
    if [ $? -eq 0 ] && [ -s "$output" ]; then
        log "Successfully downloaded $description to $output"
        return 0
    else
        log "Failed to download $description"
        return 1
    fi
}

# Linux distributions available for download
download_linux() {
    echo "Select Linux distribution to download:"
    echo "1) Debian 11"
    echo "2) Ubuntu 22.04"
    echo "3) Fedora 36"
    echo "4) Alpine Linux"
    echo "5) Arch Linux"
    echo "0) Return to main menu"
    
    read -p "Enter choice [0-5]: " choice
    
    case $choice in
        1) download_file "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.0.0-amd64-netinst.iso" "os_images/linux/debian-11.iso" "Debian 11" ;;
        2) download_file "https://releases.ubuntu.com/22.04/ubuntu-22.04-desktop-amd64.iso" "os_images/linux/ubuntu-22.04.iso" "Ubuntu 22.04" ;;
        3) download_file "https://dl.fedoraproject.org/pub/fedora/linux/releases/36/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-36-1.5.iso" "os_images/linux/fedora-36.iso" "Fedora 36" ;;
        4) download_file "https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-virt-3.16.0-x86_64.iso" "os_images/linux/alpine-3.16.iso" "Alpine Linux 3.16" ;;
        5) download_file "https://archive.archlinux.org/iso/2022.07.01/archlinux-2022.07.01-x86_64.iso" "os_images/linux/arch-2022.07.01.iso" "Arch Linux (July 2022)" ;;
        0) return ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# BSD variants available for download
download_bsd() {
    echo "Select BSD variant to download:"
    echo "1) FreeBSD 13.1"
    echo "2) OpenBSD 7.1"
    echo "3) NetBSD 9.3"
    echo "0) Return to main menu"
    
    read -p "Enter choice [0-3]: " choice
    
    case $choice in
        1) download_file "https://download.freebsd.org/releases/amd64/13.1-RELEASE/FreeBSD-13.1-RELEASE-amd64-disc1.iso" "os_images/bsd/freebsd-13.1.iso" "FreeBSD 13.1" ;;
        2) download_file "https://cdn.openbsd.org/pub/OpenBSD/7.1/amd64/install71.iso" "os_images/bsd/openbsd-7.1.iso" "OpenBSD 7.1" ;;
        3) download_file "https://cdn.netbsd.org/pub/NetBSD/NetBSD-9.3/images/NetBSD-9.3-amd64.iso" "os_images/bsd/netbsd-9.3.iso" "NetBSD 9.3" ;;
        0) return ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Miscellaneous OS images available for download
download_misc() {
    echo "Select miscellaneous OS to download:"
    echo "1) KolibriOS"
    echo "2) ReactOS 0.4.15"
    echo "3) Haiku R1/beta4"
    echo "0) Return to main menu"
    
    read -p "Enter choice [0-3]: " choice
    
    case $choice in
        1) download_file "https://github.com/kolibrios/kolibrios/releases/download/latest/kolibri.iso" "os_images/misc/kolibrios.iso" "KolibriOS" ;;
        2) download_file "https://github.com/reactos/reactos/releases/download/0.4.15/ReactOS-0.4.15-live.zip" "os_images/misc/reactos-0.4.15.zip" "ReactOS 0.4.15" ;;
        3) download_file "https://cdn.haiku-os.org/haiku-release/r1beta4/haiku-r1beta4-x86_64-anyboot.iso" "os_images/misc/haiku-r1beta4.iso" "Haiku R1/beta4" ;;
        0) return ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Main menu
main_menu() {
    while true; do
        echo "=================================================="
        echo "QEMU OS Image Downloader"
        echo "=================================================="
        echo "Select OS category to download:"
        echo "1) Linux Distributions"
        echo "2) BSD Variants"
        echo "3) Miscellaneous OS"
        echo "4) Exit"
        
        read -p "Enter choice [1-4]: " choice
        
        case $choice in
            1) download_linux ;;
            2) download_bsd ;;
            3) download_misc ;;
            4) break ;;
            *) echo "Invalid option. Please try again." ;;
        esac
        
        echo ""
    done
}

# Create output command directory if it doesn't exist
mkdir -p output/commands

# Display welcome message
echo "========================================================"
echo "QEMU OS Image Downloader"
echo "This interactive script will help you download OS images for QEMU exploration."
echo "Images will be saved in the 'os_images' directory."
echo "========================================================"
echo ""

# Start the main menu
main_menu

# Create a README file with information on how to use the images
cat > os_images/README.md << 'EOF'
# OS Images for QEMU Exploration

This directory contains various OS images for use with QEMU.

## Running an OS image with QEMU

Basic command:
```
qemu-system-x86_64 -m 2G -boot d -cdrom path/to/image.iso
```

With networking:
```
qemu-system-x86_64 -m 2G -boot d -cdrom path/to/image.iso -net nic -net user
```

With KVM acceleration (if available):
```
qemu-system-x86_64 -m 2G -boot d -cdrom path/to/image.iso -enable-kvm
```

## Directory Structure

- linux/ - Linux distribution images
- bsd/ - BSD variant images
- windows/ - Windows images (if downloaded)
- misc/ - Other miscellaneous OS images
EOF

echo ""
echo "A README with usage instructions has been created at os_images/README.md"
echo "Your download activities have been logged in the command history."