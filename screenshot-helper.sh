#!/bin/bash

# Create output directories if they don't exist
mkdir -p output/screenshots
mkdir -p output/videos

# Function to capture screenshots
capture_screenshot() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local filename="output/screenshots/screenshot_$timestamp.png"
    
    # Check if we have scrot installed
    if command -v scrot &> /dev/null; then
        echo "Capturing screenshot using scrot..."
        scrot "$filename"
    # Check if we have gnome-screenshot
    elif command -v gnome-screenshot &> /dev/null; then
        echo "Capturing screenshot using gnome-screenshot..."
        gnome-screenshot -f "$filename"
    # Check if we have import from ImageMagick
    elif command -v import &> /dev/null; then
        echo "Capturing screenshot using ImageMagick import..."
        echo "Click on the window you want to capture."
        import "$filename"
    else
        echo "No screenshot tool found. Please install scrot, gnome-screenshot, or ImageMagick."
        echo "You can manually save screenshots to output/screenshots/ directory."
        return 1
    fi
    
    if [ -f "$filename" ]; then
        echo "Screenshot saved to $filename"
        # Log the screenshot capture to command history
        echo "$(date +"%Y-%m-%d %H:%M:%S") Captured screenshot: $filename" >> output/commands/command_history.txt
        return 0
    else
        echo "Failed to capture screenshot"
        return 1
    fi
}

# Function to record screen
record_screen() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local filename="output/videos/recording_$timestamp.mp4"
    
    # Check if we have ffmpeg installed
    if command -v ffmpeg &> /dev/null; then
        echo "Recording screen using ffmpeg..."
        echo "Press q to stop recording."
        
        # Detect display and resolution
        local display=":0.0"
        local resolution=$(xdpyinfo | grep dimensions | awk '{print $2}')
        
        ffmpeg -f x11grab -s "$resolution" -i "$display" -r 15 -c:v libx264 -preset ultrafast "$filename"
    # Check if we have simplescreenrecorder
    elif command -v simplescreenrecorder &> /dev/null; then
        echo "Please use SimplescreenRecorder GUI to record your screen."
        echo "Save the recording to output/videos/ directory when done."
        simplescreenrecorder
        return 0
    else
        echo "No screen recording tool found. Please install ffmpeg or simplescreenrecorder."
        echo "You can manually save recordings to output/videos/ directory."
        return 1
    fi
    
    if [ -f "$filename" ]; then
        echo "Screen recording saved to $filename"
        # Log the recording to command history
        echo "$(date +"%Y-%m-%d %H:%M:%S") Recorded screen: $filename" >> output/commands/command_history.txt
        return 0
    else
        echo "Failed to record screen"
        return 1
    fi
}

# Add aliases to .bashrc if they don't exist
if ! grep -q "alias screenshot=" ~/.bashrc; then
    echo "# Screenshot and recording aliases" >> ~/.bashrc
    echo "alias screenshot='$(pwd)/screenshot-helper.sh screenshot'" >> ~/.bashrc
    echo "alias record='$(pwd)/screenshot-helper.sh record'" >> ~/.bashrc
    echo "Aliases added to ~/.bashrc. Please run 'source ~/.bashrc' to use them."
fi

# Command line interface
case "$1" in
    screenshot)
        capture_screenshot
        ;;
    record)
        record_screen
        ;;
    *)
        echo "Usage: $0 {screenshot|record}"
        echo "  screenshot - Capture a screenshot of your screen"
        echo "  record     - Record a video of your screen"
        echo ""
        echo "Screenshots are saved to: output/screenshots/"
        echo "Recordings are saved to:  output/videos/"
        ;;
esac