#!/bin/bash

# Create output directories
mkdir -p output/commands
mkdir -p output/screenshots
mkdir -p output/videos

# Path to store commands
COMMAND_LOG="output/commands/command_history.txt"

# Setup command tracking by modifying .bashrc
echo "
# Command tracking for QEMU exploration
export PROMPT_COMMAND='echo \$(date \"+%Y-%m-%d %H:%M:%S\") \"\$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\")\" >> $COMMAND_LOG'
" >> ~/.bashrc

# Create a README to explain how to use the tracking system
cat > output/README.md << 'EOF'
# Command Tracking System

This system automatically tracks your commands during the QEMU exploration.

## Command Tracking

All commands you enter in the terminal are automatically logged to:
`output/commands/command_history.txt`

This happens automatically and requires no additional action.

## Review Your Progress

To review your command history:
```bash
cat output/commands/command_history.txt
```
EOF

echo "Command tracking system has been set up!"
echo "Please run 'source ~/.bashrc' or restart your terminal to activate tracking."
echo "See output/README.md for usage instructions."