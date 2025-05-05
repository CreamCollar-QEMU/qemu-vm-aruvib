#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Step 1: Docker login (this will prompt for username/password interactively)
docker login

# Step 2: Build Docker image with tag 'qemu-virtualization'
docker build -t qemu-virtualization .

# Step 3: Run the container interactively with root user, auto-remove after exit
docker run -it --rm -e USER=root qemu-virtualization

# Step 4: Make all files executable recursively
chmod -R +x .

# Step 5: Execute the tracker script
./command-tracker.sh
