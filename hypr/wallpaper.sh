#!/bin/bash
# HyprMac Wallpaper Script
# Automatically detects image or video wallpaper and uses appropriate daemon

WALL="$HOME/Pictures/wallpaper/current"  # Symlink to current wallpaper

# Check if wallpaper file exists
if [[ -L "$WALL" ]] || [[ -f "$WALL" ]]; then
    # Resolve symlink to get real path
    REAL_WALL="$(readlink -f "$WALL")"
    
    if [[ "$REAL_WALL" == *.mp4 || "$REAL_WALL" == *.webm || "$REAL_WALL" == *.mkv || "$REAL_WALL" == *.avi || "$REAL_WALL" == *.mov ]]; then
        # Video wallpaper - use gslapper
        pkill -f gslapper 2>/dev/null
        gslapper -o loop '' "$REAL_WALL" &
    else
        # Image wallpaper - use swww
        pkill -f gslapper 2>/dev/null
        swww img "$REAL_WALL" --transition-type wipe --transition-fps 60 --transition-duration 1.5
    fi
else
    echo "No wallpaper found at $WALL"
    echo "Create a symlink: ln -sf /path/to/your/wallpaper $WALL"
fi