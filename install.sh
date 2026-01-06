#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting installation of macOS-like Hyprland dotfiles (Updated for new features)...${NC}"

# Step 1: Update system
echo -e "${GREEN}Updating system packages...${NC}"
sudo pacman -Syu --noconfirm

# Step 2: Install yay if not present (AUR helper)
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}yay not found. Installing yay...${NC}"
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Step 3: Install required system packages
echo -e "${GREEN}Installing Hyprland and dependencies...${NC}"
sudo pacman -S --needed --noconfirm \
    hyprland \
    swaync \
    gtk3 \
    gtk-layer-shell \
    swww \
    python \
    python-pygobject \
    python-psutil \
    python-pillow \
    python-requests \
    python-ijson \
    python-setproctitle \
    ttf-font-awesome \
    otf-font-awesome \
    kitty \
    nautilus \
    gnome-tweaks \
    brightnessctl \
    playerctl \
    polkit \
    seatd \
    xorg-xwayland \
    hyprpaper \
    waybar \
    bluez \
    bluez-utils  # Optional fallback

# Step 4: Install AUR packages
echo -e "${GREEN}Installing AUR packages and fonts...${NC}"
yay -S --needed --noconfirm otf-apple-sf-pro ttf-nerd-fonts-symbols anyrun hyprlock gslapper

# Step 5: Enable services
echo -e "${GREEN}Enabling necessary services...${NC}"
sudo systemctl enable --now seatd.service
sudo systemctl enable --now bluetooth.service

# Step 6: Install Fabric
echo -e "${GREEN}Installing Fabric framework...${NC}"
python -m pip install --user git+https://github.com/Fabric-Development/fabric.git

# Step 7: Install Hyprspace plugin (Workspace Overview)
echo -e "${GREEN}Installing Hyprspace plugin...${NC}"
hyprpm add https://github.com/KZDKM/Hyprspace
hyprpm enable Hyprspace

# Step 8: Create directories (if not exist) and copy files (overwrite existing)
echo -e "${GREEN}Setting up dotfiles directories and copying files...${NC}"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Hyprland main config and related files
mkdir -p ~/.config/hypr
cp -f "$SCRIPT_DIR/hyprland.conf" ~/.config/hypr/hyprland.conf && echo -e "${GREEN}Copied hyprland.conf${NC}"
cp -f "$SCRIPT_DIR/hyprlock.conf" ~/.config/hypr/hyprlock.conf && echo -e "${GREEN}Copied hyprlock.conf${NC}"
mkdir -p ~/.config/hypr/scripts
cp -f "$SCRIPT_DIR/wallpaper.sh" ~/.config/hypr/scripts/wallpaper.sh && chmod +x ~/.config/hypr/scripts/wallpaper.sh && echo -e "${GREEN}Copied and made executable wallpaper.sh${NC}"

# Kitty config
mkdir -p ~/.config/kitty
cp -f "$SCRIPT_DIR/kitty.conf" ~/.config/kitty/kitty.conf && echo -e "${GREEN}Copied kitty.conf${NC}"

# mac-hypr Fabric widgets
mkdir -p ~/.config/mac-hypr/styles ~/.config/mac-hypr/widgets
cp -rf "$SCRIPT_DIR/mac-hypr/"* ~/.config/mac-hypr/ && echo -e "${GREEN}Copied mac-hypr files${NC}"
chmod +x ~/.config/mac-hypr/toggle_control_center.sh && echo -e "${GREEN}Made toggle script executable${NC}"

# Anyrun (Spotlight launcher)
mkdir -p ~/.config/anyrun
cp -f "$SCRIPT_DIR/anyrun/config.ron" ~/.config/anyrun/config.ron && echo -e "${GREEN}Copied anyrun config.ron${NC}"
cp -f "$SCRIPT_DIR/anyrun/style.css" ~/.config/anyrun/style.css && echo -e "${GREEN}Copied anyrun style.css${NC}"

# SwayNC (Notification Center)
mkdir -p ~/.config/swaync
cp -f "$SCRIPT_DIR/swaync/config.json" ~/.config/swaync/config.json && echo -e "${GREEN}Copied swaync config.json${NC}"
cp -f "$SCRIPT_DIR/swaync/style.css" ~/.config/swaync/style.css && echo -e "${GREEN}Copied swaync style.css${NC}"

echo -e "${GREEN}Installation complete! Restart Hyprland or reboot.${NC}"
echo -e "${YELLOW}Ensure hyprland.conf includes binds/execs for new features (e.g., anyrun, swaync, hyprlock, wallpaper). Add 'exec-once = python ~/.config/mac-hypr/main.py' if missing.${NC}"
echo -e "${YELLOW}Note: Install Timeshift for backups before heavy use.${NC}"