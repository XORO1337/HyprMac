# macOS Tahoe on Arch Linux - Installation Guide

## Overview

This guide will help you install and configure a pixel-perfect macOS Tahoe replica on Arch Linux using Hyprland window manager.

## Prerequisites

- **Arch Linux** (or Arch-based distribution like Manjaro, EndeavourOS)
- **Root/sudo access**
- **Internet connection**
- **At least 4GB RAM**
- **OpenGL 3.3+ compatible GPU**

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/macos-tahoe-replica.git
cd macos-tahoe-replica
```

### 2. Run Installation Script

```bash
./scripts/install.sh
```

This script will:
- Install all required dependencies
- Setup AUR helper (yay)
- Install Hyprland and related packages
- Install development tools
- Configure system services

### 3. Apply Configurations

```bash
./scripts/setup.sh
```

This script will:
- Backup existing configurations
- Apply Hyprland, Waybar, and AGS configs
- Setup wallpaper engine
- Configure terminal and shell
- Create desktop entries

### 4. Apply macOS Theme

```bash
./scripts/theme.sh
```

This script will:
- Install macOS Sierra GTK theme
- Install macOS icons and cursors
- Install San Francisco fonts
- Apply theme system-wide

### 5. Reboot

```bash
reboot
```

After reboot, select "Hyprland" from your display manager.

## Detailed Installation

### System Requirements

#### Minimum Requirements
- **CPU**: 2 GHz dual-core
- **RAM**: 4 GB
- **Storage**: 20 GB free space
- **GPU**: OpenGL 3.3 support

#### Recommended Requirements
- **CPU**: 3 GHz quad-core
- **RAM**: 8 GB
- **Storage**: 50 GB free space
- **GPU**: Vulkan support

### Step-by-Step Installation

#### Step 1: Update System

```bash
sudo pacman -Syu
```

#### Step 2: Install Base Dependencies

```bash
sudo pacman -S --needed base-devel git curl wget unzip cmake meson ninja
```

#### Step 3: Install Wayland and Hyprland

```bash
sudo pacman -S --needed wayland wayland-protocols wayland-utils wlroots
sudo pacman -S --needed hyprland hyprpaper hyprpicker hyprlock hypridle
```

#### Step 4: Install AUR Helper

```bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

#### Step 5: Install AUR Packages

```bash
yay -S --needed waybar-hyprland-git wofi-git swww gSlapper ags-git
```

#### Step 6: Install Additional Software

```bash
# File managers
sudo pacman -S --needed nautilus thunar

# Terminal emulators
sudo pacman -S --needed alacritty kitty

# Development tools
sudo pacman -S --needed code neovim

# Media applications
sudo pacman -S --needed vlc spotify

# System utilities
sudo pacman -S --needed neofetch htop btop
```

#### Step 7: Install macOS Theme

```bash
# Install theme dependencies
yay -S --needed gtk-engine-murrine sassc

# Install macOS theme
cd /tmp
git clone https://github.com/vinceliuice/macos-sierra-gtk-theme.git
cd macos-sierra-gtk-theme
./install.sh
```

#### Step 8: Install macOS Icons

```bash
cd /tmp
git clone https://github.com/vinceliuice/macos-sierra-icon-theme.git
cd macos-sierra-icon-theme
./install.sh
```

#### Step 9: Install San Francisco Fonts

```bash
cd /tmp
git clone https://github.com/AppleDesignResources/SanFranciscoFont.git
mkdir -p ~/.fonts/SF-Pro
cp SanFranciscoFont/*.ttf ~/.fonts/SF-Pro/
fc-cache -fv
```

#### Step 10: Apply Configurations

```bash
# Copy configuration files
cp -r config/hyprland.conf ~/.config/hypr/
cp -r config/waybar ~/.config/
cp -r config/ags ~/.config/
cp -r config/wofi ~/.config/

# Make scripts executable
chmod +x scripts/*.sh
chmod +x ~/.local/bin/*
```

#### Step 11: Configure Theme

```bash
# Apply GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'macOS-Sierra'
gsettings set org.gnome.desktop.interface icon-theme 'macOS-Sierra'
gsettings set org.gnome.desktop.interface cursor-theme 'macOS'

# Apply Qt theme
echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> ~/.profile
echo 'export QT_STYLE_OVERRIDE=kvantum' >> ~/.profile
```

#### Step 12: Create Default Wallpapers

```bash
mkdir -p ~/Documents/Wallpapers
# Add your wallpapers to this directory
```

#### Step 13: Setup Autostart

```bash
# Add to ~/.config/autostart/hyprland.desktop
[Desktop Entry]
Type=Application
Name=Hyprland Services
Exec=~/.config/hypr/autostart.sh
```

#### Step 14: Reboot

```bash
reboot
```

## Post-Installation

### First Boot

1. **Select Hyprland** from your display manager
2. **Wait for initial setup** (may take a few seconds)
3. **Configure display resolution** if needed
4. **Set up wallpapers** using the wallpaper picker

### Basic Usage

#### Key Bindings

- **Super+Q**: Application launcher
- **Super+Space**: Command runner
- **Super+Return**: Terminal
- **Super+W**: Close window
- **Super+M**: Toggle fullscreen
- **Super+Tab**: Window switcher
- **Super+L**: Lock screen
- **Super+Print**: Screenshot

#### Desktop Features

- **Dock**: Animated dock at the bottom with magnification
- **Top Bar**: macOS-style menu bar with system controls
- **Spotlight**: Press Super+Space for system search
- **Control Center**: Click gear icon for system controls
- **Mission Control**: Window overview (configure in Hyprland)

### Customization

#### Changing Wallpapers

```bash
# Launch wallpaper picker
wallpaper-picker

# Or use keyboard shortcut
Super+W
```

#### Modifying Configurations

- **Hyprland**: `~/.config/hypr/hyprland.conf`
- **Waybar**: `~/.config/waybar/config`
- **AGS**: `~/.config/ags/config.js`
- **Theme**: `~/.config/gtk-3.0/settings.ini`

#### Installing Additional Applications

```bash
# Using pacman
sudo pacman -S application-name

# Using yay (AUR)
yay -S application-name
```

## Troubleshooting

### Common Issues

#### Black Screen on Boot

1. Check GPU drivers: `lspci | grep VGA`
2. Install appropriate drivers:
   - Intel: `sudo pacman -S mesa`
   - NVIDIA: `sudo pacman -S nvidia nvidia-utils`
   - AMD: `sudo pacman -S mesa vulkan-radeon`

#### No Audio

1. Check PipeWire: `pactl info`
2. Restart audio: `systemctl --user restart pipewire`
3. Install pavucontrol: `sudo pacman -S pavucontrol`

#### Theme Not Applied

1. Check theme installation: `ls ~/.themes`
2. Apply manually: `gsettings set org.gnome.desktop.interface gtk-theme 'macOS-Sierra'`
3. Restart applications

#### Fonts Not Working

1. Check font installation: `fc-list | grep "SF Pro"`
2. Update font cache: `fc-cache -fv`
3. Restart applications

### Getting Help

1. **Check logs**: `journalctl -xe`
2. **Hyprland logs**: `~/.cache/hyprland/hyprland.log`
3. **Waybar logs**: Run `waybar` in terminal
4. **AGS logs**: Run `ags` in terminal

### Performance Tuning

#### Reduce Animation Lag

```bash
# In ~/.config/hypr/hyprland.conf
animations {
    enabled = true
    bezier = default, 0.25, 0.46, 0.45, 0.94
}
```

#### Improve Battery Life

```bash
# Install TLP
sudo pacman -S tlp
tlp start
```

#### Optimize for NVIDIA

```bash
# Add to ~/.config/hypr/hyprland.conf
env = GBM_BACKEND,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```

## Advanced Configuration

### Multi-Monitor Setup

```bash
# In ~/.config/hypr/hyprland.conf
monitor=HDMI-A-1,1920x1080,0x0,1
monitor=eDP-1,1920x1080,1920x0,1
```

### Custom Keybindings

```bash
# In ~/.config/hypr/hyprland.conf
bind = SUPER, E, exec, nautilus
bind = SUPER, C, exec, code
```

### Wallpaper Slideshow

```bash
# Create slideshow script
cat > ~/.local/bin/slideshow.sh << 'EOF'
#!/bin/bash
WALLPAPERS=(~/Documents/Wallpapers/*)
while true; do
    WALLPAPER=${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}
    swww img "$WALLPAPER"
    sleep 300
done
EOF
chmod +x ~/.local/bin/slideshow.sh
```

## Uninstallation

To completely remove macOS Tahoe:

```bash
# Run uninstall script
./scripts/uninstall.sh

# Or manually remove
rm -rf ~/.config/hypr
rm -rf ~/.config/waybar
rm -rf ~/.config/ags
rm -rf ~/.themes/macos-sierra-gtk-theme
rm -rf ~/.icons/macos-sierra-icon-theme
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Credits

- **Hyprland**: [vaxerski](https://github.com/vaxerski)
- **macOS Sierra Theme**: [vinceliuice](https://github.com/vinceliuice)
- **San Francisco Fonts**: Apple Inc.
- **Waybar**: [Alexays](https://github.com/Alexays)
- **AGS**: [Aylur](https://github.com/Aylur)

## Support

For support:

1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue with detailed information
4. Join the community Discord/IRC

---

**Note**: This project is for educational and personal use. macOS is a trademark of Apple Inc.