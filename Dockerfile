FROM ubuntu:22.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install QEMU and dependencies
RUN apt-get update && apt-get install -y \
    qemu-system \
    qemu-utils \
    qemu-efi \
    libvirt-clients \
    libvirt-daemon-system \
    bridge-utils \
    uml-utilities \
    virt-manager \
    curl \
    wget \
    unzip \
    git \
    vim \
    nano \
    python3 \
    python3-pip \
    zip \
    scrot \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /qemu-exploration

# Copy download script
COPY download.sh /qemu-exploration/download.sh
RUN chmod +x /qemu-exploration/download.sh

# Copy tracking scripts
COPY command-tracker.sh /qemu-exploration/command-tracker.sh
COPY submit-assignment.sh /qemu-exploration/submit-assignment.sh
COPY screenshot-helper.sh /qemu-exploration/screenshot-helper.sh
RUN chmod +x /qemu-exploration/command-tracker.sh
RUN chmod +x /qemu-exploration/submit-assignment.sh
RUN chmod +x /qemu-exploration/screenshot-helper.sh

# Create output directories
RUN mkdir -p /qemu-exploration/output/commands
RUN mkdir -p /qemu-exploration/output/screenshots
RUN mkdir -p /qemu-exploration/output/videos
RUN mkdir -p /qemu-exploration/submissions

# Set up command tracking in .bashrc
RUN echo '\n\
# Command tracking for QEMU exploration\n\
export PROMPT_COMMAND="echo \$(date \"+%Y-%m-%d %H:%M:%S\") \"\$(history 1 | sed \"s/^[ ]*[0-9]\\+[ ]*//\")\" >> /qemu-exploration/output/commands/command_history.txt"\n\
\n\
# Alias for submission\n\
alias submit-assignment="/qemu-exploration/submit-assignment.sh"\n\
\n\
# Aliases for capturing screenshots and recordings\n\
alias screenshot="/qemu-exploration/screenshot-helper.sh screenshot"\n\
alias record="/qemu-exploration/screenshot-helper.sh record"\n\
' >> /root/.bashrc

# Create a README file
RUN echo '\
# QEMU Exploration Environment\n\
\n\
This environment is set up for exploring different operating systems with QEMU.\n\
\n\
## Getting Started\n\
\n\
1. Run the download script to fetch OS images:\n\
   ```\n\
   ./download.sh\n\
   ```\n\
\n\
2. Your commands are automatically tracked in `/qemu-exploration/output/commands/command_history.txt`\n\
\n\
3. Capture screenshots and recordings:\n\
   ```\n\
   screenshot # To take a screenshot\n\
   record     # To record your screen\n\
   ```\n\
   Screenshots will be saved to `/qemu-exploration/output/screenshots/`\n\
   Videos will be saved to `/qemu-exploration/output/videos/`\n\
\n\
4. When ready to submit your assignment, use:\n\
   ```\n\
   submit-assignment\n\
   ```\n\
\n\
## Submission Process\n\
\n\
The submission process will guide you through creating a complete submission package with:\n\
- Command history\n\
- Assignment details\n\
- Space for screenshots and videos\n\
- Space for additional artifacts\n\
\n\
Your submission will be saved in the `/qemu-exploration/submissions/` directory.\n\
' > /qemu-exploration/README.md

# Command to run when container starts
CMD ["/bin/bash", "-c", "cat /qemu-exploration/README.md && /bin/bash"]