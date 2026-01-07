#!/bin/bash
chmod +x ~/.config/hypr/scripts/start_wallpaper.sh

WALL="$HOME/Pictures/wallpaper/current"  # Put your wallpaper here or symlink

if [[ -f "$WALL" ]]; then
    if [[ "$WALL" == *.mp4 || "$WALL" == *.webm || "$WALL" == *.mkv ]]; then
        pkill gslapper
        gslapper -o loop '' "$WALL"
    else
        swww img "$WALL" --transition-type wipe --transition-fps 60 --transition-duration 1.5
    fi
fi