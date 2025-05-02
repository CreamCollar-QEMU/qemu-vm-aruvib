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
