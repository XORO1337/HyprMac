# HyprMac 🍎

**A polished macOS-style desktop environment for Hyprland, powered by AGS (Aylur's GTK Shell)**

Transform your Hyprland desktop into a beautiful macOS-like experience with a native menu bar, dock, control center, and more.

![HyprMac Preview](https://via.placeholder.com/800x500?text=HyprMac+Preview)

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Menu Bar** | Top bar with Apple logo, active app name, workspaces, system tray, clock |
| **Dock** | macOS-style dock with hover magnification, running indicators, and app shortcuts |
| **Control Center** | WiFi, Bluetooth, Night Shift, Do Not Disturb, brightness, volume, media controls |
| **Launcher** | Spotlight-style app launcher (Super+D) |
| **Notifications** | Beautiful popup notifications with actions |
| **OSD** | On-screen display for volume/brightness changes |
| **Mission Control** | Workspace overview with hyprexpo plugin |
| **Lock Screen** | Hyprlock with macOS-inspired design |
| **Wallpapers** | Animated wallpaper support with swww |
| **Blur Effects** | Frosted glass effect throughout the UI |

## 📦 Components

- **AGS (Aylur's GTK Shell)** - Main widget framework
- **Hyprland** - Wayland compositor
- **SwayNC** - Notification center (backup)
- **Anyrun** - Alternative launcher
- **Hyprlock** - Lock screen
- **swww** - Wallpaper daemon
- **Gammastep** - Night Shift (blue light filter)

## 🚀 Installation

### Requirements
- Arch Linux (or Arch-based distribution)
- Hyprland window manager

### Quick Install

```bash
git clone https://github.com/XORO1337/HyprMac.git
cd HyprMac
chmod +x install.sh
./install.sh
```

The installation script will:
1. Update your system
2. Install AGS and all dependencies
3. Install required fonts (SF Pro, Font Awesome)
4. Enable system services (bluetooth, NetworkManager)
5. Install hyprexpo plugin for Mission Control
6. Copy all configuration files

### Post-Installation

1. **Set a wallpaper**: Place your wallpaper at `~/Pictures/wallpaper/current`
2. **Restart Hyprland**: `hyprctl dispatch exit` or reboot
3. **Enjoy!** 🎉

## ⌨️ Keybindings

| Keybind | Action |
|---------|--------|
| `Super + D` | Open Launcher (Spotlight) |
| `Super + Space` | Open Anyrun (alternative) |
| `Super + C` | Toggle Control Center |
| `Super + N` | Toggle Notification Center |
| `Super + S` | Mission Control (hyprexpo) |
| `Super + L` | Lock Screen |
| `Super + Q` | Close Window |
| `Super + F` | Toggle Floating |
| `Super + M` | Toggle Fullscreen |
| `Super + T` | Open Terminal (Kitty) |
| `Super + E` | Open File Manager (Nautilus) |
| `Super + 1-9` | Switch Workspace |

## 📁 Project Structure

```
HyprMac/
├── ags/                      # AGS configuration
│   ├── config.js             # Main AGS config (entry point)
│   ├── style.css             # Compiled CSS (from SCSS)
│   ├── scss/                 # SCSS source files
│   │   ├── main.scss         # Main SCSS entry
│   │   ├── _variables.scss   # Colors, dimensions, fonts
│   │   ├── _mixins.scss      # Reusable style patterns
│   │   ├── _bar.scss         # Top menu bar styles
│   │   ├── _dock.scss        # Bottom dock styles
│   │   ├── _controlcenter.scss # Control center styles
│   │   ├── _launcher.scss    # App launcher styles
│   │   ├── _notifications.scss # Notification styles
│   │   └── _osd.scss         # OSD styles
│   ├── services/             # Custom AGS services
│   │   ├── index.js          # Services export
│   │   ├── brightness.js     # Screen brightness service
│   │   ├── nightshift.js     # Night Shift (gammastep)
│   │   └── dnd.js            # Do Not Disturb (swaync)
│   └── widgets/              # Widget modules
│       ├── bar.js            # Top menu bar
│       ├── dock.js           # Bottom dock
│       ├── controlcenter.js  # Control center panel
│       ├── launcher.js       # App launcher (Spotlight)
│       ├── notifications.js  # Notification popups
│       └── osd.js            # Volume/brightness OSD
├── hypr/                     # Hyprland configuration
│   ├── hyprland.conf         # Main config
│   ├── hyprlock.conf         # Lock screen config
│   └── wallpaper.sh          # Wallpaper script
├── kitty/                    # Kitty terminal config
├── anyrun/                   # Anyrun launcher config
├── swaync/                   # SwayNC notification config
├── install.sh                # Installation script
└── README.md
```

## 🎨 Customization

### Changing Colors

The project uses SCSS for styling with Catppuccin Mocha colors. Edit `~/.config/ags/scss/_variables.scss`:

```scss
// Change accent color
$accent: #89b4fa;  // Default blue
$accent: #cba6f7;  // Mauve alternative
$accent: #a6e3a1;  // Green alternative
```

Then recompile by restarting AGS, or run:
```bash
sassc ~/.config/ags/scss/main.scss ~/.config/ags/style.css
```

### Adding Dock Apps

Edit `~/.config/ags/widgets/dock.js` and modify the `DOCK_APPS` array:

```javascript
const DOCK_APPS = [
    'firefox',
    'code',
    'kitty',
    // Add your apps here
];
```

### Changing Fonts

The default font is SF Pro. To change it, edit the CSS:

```css
* {
    font-family: "Your Font", sans-serif;
}
```

## 🔧 Troubleshooting

### AGS not starting
```bash
# Check AGS logs
ags --quit
ags 2>&1 | head -50
```

### Widgets not appearing
- Ensure `gtk-layer-shell` is installed
- Check that Hyprland layer rules are correct

### Control Center not toggling
```bash
# Test toggle command
ags -t control-center
```

### Hyprexpo not working
```bash
# Reinstall plugin
hyprpm update
hyprpm enable hyprexpo
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📜 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - The amazing Wayland compositor
- [AGS (Aylur's GTK Shell)](https://github.com/Aylur/ags) - The widget framework
- [Catppuccin](https://github.com/catppuccin) - Color palette inspiration
- Apple - For the design inspiration

---

**Enjoy your macOS-like Hyprland desktop!** 🍎✨
