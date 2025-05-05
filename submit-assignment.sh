#!/bin/bash

# Create submission directory
mkdir -p submissions

# Function to create a submission
create_submission() {
    # Generate timestamp for unique submission ID
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    SUBMISSION_ID="submission_$TIMESTAMP"
    SUBMISSION_DIR="submissions/$SUBMISSION_ID"
    
    mkdir -p "$SUBMISSION_DIR"
    
    # Copy entire output folder contents to submission
    if [ -d "output" ]; then
        # Copy command history
        if [ -f "output/commands/command_history.txt" ]; then
            mkdir -p "$SUBMISSION_DIR/commands"
            cp output/commands/command_history.txt "$SUBMISSION_DIR/commands/command_history.txt"
        fi
        
        # Copy screenshots
        if [ -d "output/screenshots" ]; then
            mkdir -p "$SUBMISSION_DIR/screenshots"
            cp -r output/screenshots/* "$SUBMISSION_DIR/screenshots/" 2>/dev/null || true
        fi
        
        # Copy videos
        if [ -d "output/videos" ]; then
            mkdir -p "$SUBMISSION_DIR/videos"
            cp -r output/videos/* "$SUBMISSION_DIR/videos/" 2>/dev/null || true
        fi
    fi
    
    # Prompt user for submission details
    echo "Creating assignment submission: $SUBMISSION_ID"
    echo "----------------------------------------------"
    echo "Please answer the following questions to complete your submission:"
    
    # Capture user name
    read -p "Your Name: " USER_NAME
    
    # Capture assignment details
    read -p "Assignment Number/Name: " ASSIGNMENT_NAME
    
    # Capture summary of work done
    echo "Please provide a summary of your work (type 'EOF' on a new line when done):"
    SUMMARY=""
    while IFS= read -r line; do
        [[ "$line" == "EOF" ]] && break
        SUMMARY+="$line"$'\n'
    done
    
    # Generate activity summary based on command history
    if [ -f "output/commands/command_history.txt" ]; then
        echo "Analyzing your work activity..."
        
        # Count total commands
        TOTAL_COMMANDS=$(wc -l < output/commands/command_history.txt)
        
        # Get unique commands (excluding timestamps)
        UNIQUE_COMMANDS=$(cat output/commands/command_history.txt | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} //' | sort | uniq | wc -l)
        
        # Find most used commands
        echo "Your most frequently used commands were:"
        MOST_USED=$(cat output/commands/command_history.txt | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} //' | sort | uniq -c | sort -nr | head -5)
        
        # Check for QEMU specific commands
        QEMU_COMMANDS=$(grep -c "qemu" output/commands/command_history.txt)
        
        # Generate activity assessment
        if [ $QEMU_COMMANDS -gt 20 ]; then
            EXPLORATION_ASSESSMENT="Your exploration shows in-depth use of QEMU virtualization tools."
        elif [ $QEMU_COMMANDS -gt 10 ]; then
            EXPLORATION_ASSESSMENT="Your exploration shows moderate use of QEMU virtualization tools."
        elif [ $QEMU_COMMANDS -gt 0 ]; then
            EXPLORATION_ASSESSMENT="Your exploration shows basic use of QEMU virtualization tools."
        else
            EXPLORATION_ASSESSMENT="Your command history doesn't show direct use of QEMU commands. Make sure to document any manual VM configurations you made."
        fi
    else
        TOTAL_COMMANDS="N/A"
        UNIQUE_COMMANDS="N/A"
        QEMU_COMMANDS="N/A"
        MOST_USED="No command history available"
        EXPLORATION_ASSESSMENT="No command history found to analyze activity."
    fi
    
    # Create submission README with proper markdown formatting
    cat > "$SUBMISSION_DIR/README.md" << EOF
# QEMU Exploration Assignment Submission

## Submission ID: $SUBMISSION_ID
## Student: $USER_NAME
## Assignment: $ASSIGNMENT_NAME
## Date: $(date +"%Y-%m-%d %H:%M:%S")

## Summary
$SUMMARY

## Activity Analysis

* Total commands executed: $TOTAL_COMMANDS
* Unique commands used: $UNIQUE_COMMANDS
* QEMU-related commands: $QEMU_COMMANDS

### Most Frequently Used Commands:

\`\`\`
$MOST_USED
\`\`\`

$EXPLORATION_ASSESSMENT

## Contents

- commands/: History of all commands executed
- screenshots/: Captures of your QEMU exploration
- videos/: Demonstration recordings of your work
EOF
    
    echo "----------------------------------------------"
    echo "Submission created at: $SUBMISSION_DIR"
    echo ""
    echo "Your submission includes:"
    echo "  - All command history from your session"
    echo "  - All screenshots from the output/screenshots folder"
    echo "  - All videos from the output/videos folder"
    echo "  - Automatically generated activity analysis"
    echo ""
    echo "To create a final ZIP for submission, run:"
    echo "  cd submissions && zip -r $SUBMISSION_ID.zip $SUBMISSION_ID"
}

# Call the function
create_submission

# Commit the new submission to git if available
if command -v git &> /dev/null && [ -d ".git" ]; then
    SUBMISSION_ID=$(ls -t submissions | head -1)
    git add submissions
    git commit -m "Add submission: $SUBMISSION_ID"
    git branch -M main
    git push -u origin main 2>/dev/null || echo "Git push failed. You may need to set up a remote repository."
fi