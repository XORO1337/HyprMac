# macOS Tahoe on Arch Linux - Hyprland Edition

<p align="center">
  <img src="docs/assets/macos-tahoe-banner.png" alt="macOS Tahoe Banner" width="800">
</p>

<p align="center">
  <strong>A pixel-perfect, 1-to-1 replica of macOS Tahoe using Hyprland window manager on Arch Linux</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#customization">Customization</a> •
  <a href="#troubleshooting">Troubleshooting</a>
</p>

## 🎯 Objective

Create an indistinguishable macOS Tahoe experience on Arch Linux with:
- **Glassmorphism effects** with proper transparency and blur
- **Pixel-perfect animations** (Genie effect, Wobbly windows, Dock magnification)
- **Complete desktop environment** with all macOS features
- **60fps+ smooth performance**

## ✨ Features

### 🎨 Visual & Aesthetic
- **Glassmorphism**: Side-transparency, window blur effects
- **Traffic Light Controls**: Pixel-perfect window controls
- **macOS Sierra Theme**: GTK theme and icon set
- **San Francisco Fonts**: System-wide font replacement
- **Dynamic Wallpapers**: Support for both images and videos

### 🎬 Animations & Effects
- **Genie Effect**: Window minimizing animation
- **Scale/Zoom Effect**: Window maximizing
- **Wobbly Windows**: Physics-based window movement
- **Dock Magnification**: Smooth parabolic zoom
- **Smooth Transitions**: 60fps+ performance

### 🖥️ User Interface
- **Animated Dock**: With tooltips and magnification
- **Global Menu Bar**: macOS-style top bar with Apple menu
- **Mission Control**: Window overview
- **Hot Corners**: Configurable corner actions
- **Exposé**: Window spread

### 🚀 Launchers
- **Launchpad**: Full-screen app grid
- **Spotlight Clone**: Centered search with calculator and web
- **Wofi Integration**: Fast application launcher

### 📱 Desktop Widgets (AGS)
- **Weather**: OpenWeatherMap integration
- **Music Player**: Media controls
- **Notes**: Quick notes widget
- **Calendar**: Date and events
- **Clock**: Time and world clock
- **Control Center**: System controls
- **Notifications**: macOS-style alerts

### 🛠️ Utilities
- **Quick Look**: Space-bar file preview
- **Control Center**: Slide-out panels
- **Notifications**: macOS-style alerts
- **Split View**: Auto-tiling
- **Screen Time**: Usage tracker
- **Color Picker**: Digital Color Meter
- **Wallpaper Engine**: Video and image support

### 📁 File Management
- **Nautilus/Thunar**: Configured with side transparency
- **Quick Look**: Preview files with spacebar
- **Recent Items**: Quick access to recent files

### 🔧 System Integration
- **Network Manager**: WiFi and network controls
- **Bluetooth**: Device management
- **Audio**: PipeWire with volume controls
- **Power Management**: Battery and brightness

## 🚀 Quick Start

### Prerequisites
- **Arch Linux** (or Arch-based distribution)
- **Root/sudo access**
- **Internet connection**
- **OpenGL 3.3+ compatible GPU**

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/macos-tahoe-replica.git
cd macos-tahoe-replica

# 2. Run installation script
./scripts/install.sh

# 3. Apply configurations
./scripts/setup.sh

# 4. Apply macOS theme
./scripts/theme.sh

# 5. Reboot
reboot
```

After reboot, select "Hyprland" from your display manager.

## 📸 Screenshots

<p align="center">
  <img src="docs/assets/screenshot-desktop.png" alt="Desktop Overview" width="800">
  <br><em>Desktop Overview with Dock and Top Bar</em>
</p>

<p align="center">
  <img src="docs/assets/screenshot-spotlight.png" alt="Spotlight Search" width="800">
  <br><em>Spotlight Search with Applications and Web Results</em>
</p>

<p align="center">
  <img src="docs/assets/screenshot-control-center.png" alt="Control Center" width="400">
  <br><em>Control Center with System Controls</em>
</p>

<p align="center">
  <img src="docs/assets/screenshot-wallpaper-picker.png" alt="Wallpaper Picker" width="600">
  <br><em>Wallpaper Picker with Video and Image Support</em>
</p>

## 📋 System Requirements

### Minimum Requirements
- **OS**: Arch Linux (or Arch-based)
- **CPU**: 2 GHz dual-core processor
- **RAM**: 4 GB
- **Storage**: 20 GB free space
- **GPU**: OpenGL 3.3 support

### Recommended Requirements
- **CPU**: 3 GHz quad-core processor
- **RAM**: 8 GB
- **Storage**: 50 GB free space
- **GPU**: Vulkan support

## 🛠️ Core Technologies

- **OS**: Arch Linux
- **Compositor**: Hyprland (latest)
- **Package Managers**: pacman, yay
- **Widget System**: AGS (Advanced Gtk+ Sequencer)
- **Wallpaper Engine**: gSlapper (video), swww (images)
- **Theme**: macOS Sierra GTK Theme and Icon Set
- **Fonts**: San Francisco Pro

### Package Dependencies

#### Base System
- `hyprland` - Wayland compositor
- `wayland` - Core Wayland libraries
- `wlroots` - Wayland compositor library

#### Graphics & UI
- `gtk3` / `gtk4` - GTK toolkit
- `qt5ct` / `qt6ct` - Qt configuration
- `kvantum` - Qt theme engine
- `sassc` - SASS compiler

#### Applications
- `nautilus` / `thunar` - File managers
- `alacritty` / `kitty` - Terminal emulators
- `firefox` / `chromium` - Web browsers
- `code` / `neovim` - Code editors

#### Utilities
- `ags` - Advanced Gtk+ Sequencer
- `waybar` - Status bar
- `wofi` - Application launcher
- `dunst` - Notification daemon
- `swww` - Wallpaper daemon
- `gSlapper` - Video wallpaper engine

## 📁 Project Structure

```
macos-tahoe-replica/
├── scripts/                    # Installation and setup scripts
│   ├── install.sh             # Main installation script
│   ├── setup.sh               # Configuration setup
│   ├── theme.sh               # Theme installation
│   └── uninstall.sh           # Removal script
├── config/                     # Configuration files
│   ├── hyprland.conf          # Hyprland configuration
│   ├── waybar/                # Top bar configuration
│   │   ├── config
│   │   └── style.css
│   └── ags/                   # Widget configurations
│       ├── config.js
│       └── widgets/
├── wallpaper/                  # Wallpaper engine
│   ├── wallpaper-picker.py    # GUI wallpaper picker
│   └── config.json            # Wallpaper settings
├── utilities/                  # Desktop utilities
├── docs/                      # Documentation
│   ├── INSTALLATION.md
│   ├── CONFIGURATION.md
│   └── TROUBLESHOOTING.md
└── README.md
```

## ⚙️ Configuration

### Key Files

- **Hyprland**: `~/.config/hypr/hyprland.conf`
- **Waybar**: `~/.config/waybar/config`
- **AGS**: `~/.config/ags/config.js`
- **Theme**: `~/.config/gtk-3.0/settings.ini`
- **Wallpapers**: `~/Documents/Wallpapers/`

### Environment Variables

```bash
export GTK_THEME=macOS-Sierra
export ICON_THEME=macOS-Sierra
export CURSOR_THEME=macOS
export FONT_NAME="SF Pro Display 11"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
```

## ⌨️ Key Bindings

### Window Management
- **Super+Q**: Application launcher
- **Super+Space**: Command runner (Spotlight)
- **Super+Return**: Terminal
- **Super+N**: File manager
- **Super+W**: Close window
- **Super+M**: Toggle fullscreen
- **Super+F**: Toggle floating
- **Super+Tab**: Window switcher

### Workspaces
- **Super+1..0**: Switch to workspace 1-10
- **Super+Shift+1..0**: Move window to workspace 1-10
- **Super+S**: Toggle special workspace

### System
- **Super+L**: Lock screen
- **Super+Escape**: Power menu
- **Super+Shift+Escape**: Exit Hyprland

### Media
- **XF86AudioRaiseVolume**: Increase volume
- **XF86AudioLowerVolume**: Decrease volume
- **XF86AudioMute**: Toggle mute
- **XF86AudioPlay**: Play/Pause
- **XF86AudioNext**: Next track
- **XF86AudioPrev**: Previous track

### Screenshots
- **Super+Print**: Screenshot entire screen
- **Super+Shift+Print**: Screenshot active window
- **Super+Ctrl+Print**: Screenshot selected area

### Extras
- **Super+W**: Wallpaper picker
- **Super+Click**: Move window
- **Super+Right-Click**: Resize window

## 🎨 Customization

### Changing Wallpapers

```bash
# Launch GUI wallpaper picker
wallpaper-picker

# Or use keyboard shortcut
Super+W
```

### Modifying Animations

Edit `~/.config/hypr/hyprland.conf`:

```ini
animations {
    enabled = true
    bezier = default, 0.25, 0.46, 0.45, 0.94
    animation = windows, 1, 6, default, slide
}
```

### Custom Keybindings

```ini
# In ~/.config/hypr/hyprland.conf
bind = SUPER, E, exec, nautilus
bind = SUPER, C, exec, code
```

### Widget Configuration

Edit `~/.config/ags/config.js` to customize:
- Weather API settings
- Widget positions
- Control center items
- Notification settings

## 🔧 Troubleshooting

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

### Performance Issues

#### Reduce Animation Lag
```ini
# In ~/.config/hypr/hyprland.conf
render {
    explicit_sync = true
    damage_tracking = 2
}
```

#### Improve Battery Life
```bash
# Install TLP
sudo pacman -S tlp
tlp start
```

### Getting Help

1. **Check logs**: `journalctl -xe`
2. **Hyprland logs**: `~/.cache/hyprland/hyprland.log`
3. **Waybar logs**: Run `waybar` in terminal
4. **AGS logs**: Run `ags` in terminal

## 📦 Package Management

### Installing Applications

```bash
# Official repositories
sudo pacman -S application-name

# AUR (using yay)
yay -S application-name

# Flatpak
flatpak install application-name
```

### Recommended Applications

#### Development
- `visual-studio-code-bin` - Code editor
- `intellij-idea-community-edition` - IDE
- `neovim` - Terminal editor
- `git` - Version control

#### Media
- `spotify` - Music streaming
- `vlc` - Video player
- `obs-studio` - Screen recording
- `gimp` - Image editing

#### Utilities
- `neofetch` - System information
- `htop` - Process viewer
- `btop` - Resource monitor
- `ranger` - Terminal file manager

## 🌐 Network Configuration

### WiFi Setup

```bash
# Using nmcli
nmcli device wifi list
nmcli device wifi connect SSID password PASSWORD

# Using nmtui (text UI)
nmtui
```

### Bluetooth Setup

```bash
# Start Bluetooth service
sudo systemctl enable --now bluetooth

# Pair devices using blueman
blueman-manager
```

## 🔒 Security

### Screen Locking

```bash
# Automatic lock after 5 minutes
hypridle &

# Manual lock
hyprlock
```

### Firewall

```bash
# Install and enable firewall
sudo pacman -S ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

## 🔄 Updates

### System Updates

```bash
# Update system packages
sudo pacman -Syu

# Update AUR packages
yay -Syu

# Update theme (if needed)
cd /tmp && git clone https://github.com/vinceliuice/macos-sierra-gtk-theme.git
cd macos-sierra-gtk-theme && ./install.sh
```

### Configuration Updates

```bash
# Backup current config
cp -r ~/.config/hypr ~/.config/hypr.backup

# Apply new config
cp -r config/hyprland.conf ~/.config/hypr/
```

## 🗑️ Uninstallation

### Complete Removal

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

### Partial Removal

```bash
# Remove only theme
rm -rf ~/.themes/macos-sierra-gtk-theme
rm -rf ~/.icons/macos-sierra-icon-theme

# Reset GTK settings
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme
```

## 🤝 Contributing

Contributions are welcome! Please:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Setup

```bash
# Clone repository
git clone https://github.com/yourusername/macos-tahoe-replica.git
cd macos-tahoe-replica

# Create development branch
git checkout -b dev

# Make changes and test
# ...

# Commit changes
git add .
git commit -m "Description of changes"

# Push changes
git push origin dev
```

### Code Style

- **Shell scripts**: Use `shellcheck` for linting
- **JavaScript**: Use `eslint` with Airbnb config
- **Python**: Use `black` for formatting
- **CSS**: Use consistent indentation (2 spaces)

## 📄 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) file for details.

## 🙏 Credits

### Core Technologies
- **Hyprland**: [vaxerski](https://github.com/vaxerski) - Wayland compositor
- **Waybar**: [Alexays](https://github.com/Alexays) - Status bar
- **AGS**: [Aylur](https://github.com/Aylur) - Widget system
- **Wofi**: [cloudsnake](https://github.com/cloudsnake) - Application launcher

### Themes & Assets
- **macOS Tahoe Theme**: [vinceliuice](https://github.com/vinceliuice)
- **San Francisco Fonts**: Apple Inc.
- **macOS Icons**: Apple Inc.

### Inspiration
- **macOS**: Apple Inc.
- **Hyprland Community**: Various contributors
- **r/unixporn**: Community inspiration

## 📞 Support

### Documentation
- [Installation Guide](docs/INSTALLATION.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

### Community
- **GitHub Issues**: [Report bugs and feature requests](https://github.com/yourusername/macos-tahoe-replica/issues)
- **Discussions**: [General discussion and help](https://github.com/yourusername/macos-tahoe-replica/discussions)
- **Discord**: [Join our community server](https://discord.gg/yourserver)

### Professional Support
For commercial support or custom development:
- Email: support@yourdomain.com
- Website: https://yourdomain.com

---

<p align="center">
  <strong>Made with ❤️ for the Linux community</strong>
</p>

<p align="center">
  <em>This project is for educational and personal use. macOS is a trademark of Apple Inc.</em>
</p>