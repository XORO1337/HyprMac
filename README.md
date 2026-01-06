# HyprMac

HyprMac is a comprehensive dotfiles setup that transforms your Hyprland desktop environment into a macOS-like experience on Linux. It provides a familiar macOS interface with a menu bar, dock, widgets, and seamless integration with Hyprland's features.

## Features

- **Menu Bar**: Displays workspaces, window title, system information (CPU, RAM, battery, network, volume, clock), and window controls (minimize, maximize, close)
- **Dock**: macOS-style dock with application launchers, running app indicators, hover magnification, and right-click context menus
- **Top Bar Widgets**: Clock, weather, CPU/RAM usage, calendar, and control center
- **Control Center**: Comprehensive system controls including brightness, volume, WiFi toggle, Bluetooth, Night Shift, Do Not Disturb, and media controls (toggleable with Super+C)
- **Notification Center**: Integrated with SwayNC for notifications
- **Launcher**: Anyrun for quick application launching (Spotlight-like)
- **Lock Screen**: Hyprlock with macOS-inspired design
- **Wallpaper Management**: Automated wallpaper setting with swww
- **Workspace Overview**: Hyprspace plugin for workspace management
- **Theming**: Consistent macOS-like styling with SF Pro fonts and custom CSS

## Requirements

### System Requirements
- Arch Linux (or Arch-based distribution)
- Hyprland window manager
- GTK 3.0 with layer shell support

### Dependencies
- `hyprland` - Window manager
- `swaync` - Notification center
- `gtk3` - GUI toolkit
- `gtk-layer-shell` - Layer shell for overlays
- `swww` - Wallpaper setter
- `python` with packages: `pygobject`, `psutil`, `pillow`, `requests`, `ijson`, `setproctitle`
- `ttf-font-awesome` and `otf-font-awesome` - Icons
- `otf-apple-sf-pro` - macOS system font
- `ttf-nerd-fonts-symbols` - Additional symbols
- `kitty` - Terminal emulator
- `nautilus` - File manager
- `brightnessctl` - Brightness control
- `playerctl` - Media control
- `polkit` - Authentication
- `seatd` - Seat management
- `hyprpaper` - Wallpaper manager
- `waybar` - Status bar (optional fallback)

### AUR Packages
- `anyrun` - Application launcher
- `hyprlock` - Lock screen
- `gslapper` - Additional utilities

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/XORO1337/HyprMac.git
   cd HyprMac
   ```

2. **Run the installation script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   The script will:
   - Update your system
   - Install required packages via pacman and yay
   - Enable necessary services
   - Install the Fabric framework
   - Install Hyprspace plugin
   - Copy all configuration files to appropriate locations

3. **Restart Hyprland:**
   ```bash
   hyprctl dispatch exit
   ```
   Or reboot your system.

4. **Verify installation:**
   - Check that all services are running
   - Ensure Hyprland starts with the new configuration
   - Test the widgets by running: `python ~/.config/mac-hypr/main.py`

## Configuration

### Hyprland Configuration
The main configuration is in `~/.config/hypr/hyprland.conf`. Key bindings and settings include:
- Mod key: Super (Windows key)
- Workspaces: 1-10 with dynamic creation
- Window management: Tiling with floating exceptions
- Keybindings for applications, workspaces, and utilities

### Widget Configuration
Edit `~/.config/mac-hypr/settings.json` to customize widgets:

```json
{
    "weather_mode": "detailed",  // Options: "current", "minimal", "detailed"
    "coords": "37.7749,-122.4194",  // Latitude,longitude for weather
    "city": ""  // Alternative to coords; will geocode if set
}
```

### Styling
Customize appearance in `~/.config/mac-hypr/styles/main.css`:
- Colors, fonts, and spacing
- macOS-inspired design elements
- Transparency and blur effects

## Usage

### Key Bindings
- `Super + C`: Control Center (toggle)
- `Super + Q`: Kill active window
- `Super + Space`: Toggle floating
- `Super + F`: Toggle fullscreen
- `Super + D`: Anyrun launcher
- `Super + L`: Lock screen
- `Super + N`: Toggle notification center
- `Super + M`: Toggle menu bar
- `Super + C`: Control center
- Workspace switching: `Super + [1-10]`

### Widgets
- **Clock**: Displays current time and date
- **Weather**: Shows current conditions and forecast (configurable)
- **CPU/RAM**: System resource usage
- **Calendar**: Date picker and events
- **About**: System information dialog

### Control Center (Super+C)
- **Display**: Brightness slider and Night Shift toggle
- **Sound**: Volume slider
- **Now Playing**: Media controls (Previous, Play/Pause, Next)
- **Network**: WiFi and Bluetooth toggles
- **Focus**: Do Not Disturb toggle

### Dock
- Click application icons to launch
- Hover for magnification effect (macOS-style)
- Blue dot indicators for running applications
- Right-click for context menus (Force Quit option)
- Dynamic scaling based on mouse position

### Menu Bar
- Workspace indicators
- Active window title
- Window control buttons (red close, yellow minimize, green maximize)
- System status with icons (CPU, RAM, battery, network, volume, clock)
- Quick access to settings

## Customization

### Adding New Widgets
1. Create a new Python file in `~/.config/mac-hypr/widgets/`
2. Implement a class inheriting from appropriate GTK widget
3. Import and add to `main.py`
4. Style in `main.css`

### Theming
- Modify colors in `main.css`
- Change fonts (ensure they're installed)
- Adjust spacing and sizing

### Keybindings
Edit `hyprland.conf` to add or modify keybindings.

## Troubleshooting

### Common Issues
1. **Widgets not appearing**: Ensure Fabric is installed and GTK layer shell is working
2. **Weather not updating**: Check internet connection and API access
3. **Fonts not rendering**: Install SF Pro fonts from AUR
4. **Hyprland not starting**: Check logs with `hyprctl` or journalctl

### Logs
- Hyprland logs: `hyprctl`
- System logs: `journalctl -u seatd`
- Widget errors: Run `python ~/.config/mac-hypr/main.py` manually

### Reset Configuration
To reset to defaults:
```bash
rm -rf ~/.config/mac-hypr ~/.config/hypr ~/.config/kitty ~/.config/anyrun ~/.config/swaync
./install.sh
```

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Setup
1. Install dependencies as above
2. Clone and modify locally
3. Test changes in a VM or separate user account
4. Ensure compatibility with latest Hyprland

## Screenshots

*(Add screenshots here showing the desktop, widgets, dock, etc.)*

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Hyprland community for the amazing window manager
- Fabric framework for GTK widgets
- macOS for the inspiration
- All contributors and maintainers

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check the Hyprland documentation
- Join relevant Linux communities

---

*Enjoy your macOS-like Hyprland experience!*