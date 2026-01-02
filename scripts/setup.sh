#!/bin/bash

# macOS Tahoe Setup Script
# Applies all configurations and sets up the desktop environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Arrays to track failed operations
failed_configs=()
failed_operations=()

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to backup existing configuration
backup_config() {
    local config_name="$1"
    if [ -d "$CONFIG_DIR/$config_name" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$CONFIG_DIR/$config_name" "$BACKUP_DIR/"
        print_status "Backed up $config_name to $BACKUP_DIR"
    fi
}

# Function to apply configuration
apply_config() {
    local source="$1"
    local target="$2"
    
    if [ -d "$source" ]; then
        if ! mkdir -p "$(dirname "$target")" 2>/dev/null; then
            print_warning "Failed to create directory for: $target"
            failed_configs+=("$(basename "$target")")
            return 1
        fi
        if ! cp -r "$source" "$target" 2>/dev/null; then
            print_warning "Failed to copy configuration: $target"
            failed_configs+=("$(basename "$target")")
            return 1
        fi
        print_success "Applied configuration: $target"
    else
        print_warning "Source directory not found: $source"
        failed_configs+=("$(basename "$source")")
        return 1
    fi
}

# Function to create user directories
create_directories() {
    print_status "Creating user directories..."
    
    local dirs=(
        "$HOME/.config/hypr"
        "$HOME/.config/ags"
        "$HOME/.config/waybar"
        "$HOME/.config/wofi"
        "$HOME/.config/wallpaper"
        "$HOME/.config/gSlapper"
        "$HOME/.config/swww"
        "$HOME/.config/dunst"
        "$HOME/.config/kitty"
        "$HOME/.config/alacritty"
        "$HOME/.local/share/applications"
        "$HOME/.local/bin"
        "$HOME/Documents/Wallpapers"
        "$HOME/Pictures/Screenshots"
        "$HOME/Development"
        "$HOME/.cache/wallpaper-thumbnails"
    )
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            print_warning "Failed to create directory: $dir"
            failed_operations+=("Create directory: $(basename "$dir")")
        fi
    done
    
    print_success "User directories created"
}

# Function to apply Hyprland configuration
setup_hyprland() {
    print_status "Setting up Hyprland configuration..."
    
    backup_config "hypr"
    apply_config "$PROJECT_ROOT/config/hyprland.conf" "$CONFIG_DIR/hypr/hyprland.conf" || failed_operations+=("Hyprland main config")
    
    # Create additional Hyprland configs
    if ! cat > "$CONFIG_DIR/hypr/hypridle.conf" 2>/dev/null << 'EOF'
# Hypridle configuration for macOS Tahoe

general {
    lock_cmd = hyprlock
    before_sleep_cmd = hyprlock
    after_wake_cmd = 
    ignore_dbus_inhibit = false
    ignore_systemd_inhibit = false
}

timeout = 300, locker, hyprlock
EOF
    then
        print_warning "Failed to create hypridle.conf"
        failed_configs+=("hypridle.conf")
    fi
    
    print_success "Hyprland configuration applied"
}

# Function to apply Waybar configuration
setup_waybar() {
    print_status "Setting up Waybar configuration..."
    
    backup_config "waybar"
    apply_config "$PROJECT_ROOT/config/waybar/config" "$CONFIG_DIR/waybar/config" || failed_operations+=("Waybar config")
    apply_config "$PROJECT_ROOT/config/waybar/style.css" "$CONFIG_DIR/waybar/style.css" || failed_operations+=("Waybar style")
    
    print_success "Waybar configuration applied"
}

# Function to apply AGS configuration
setup_ags() {
    print_status "Setting up AGS configuration..."
    
    backup_config "ags"
    apply_config "$PROJECT_ROOT/config/ags" "$CONFIG_DIR/ags" || failed_operations+=("AGS config")
    
    # Make AGS scripts executable
    if ! find "$CONFIG_DIR/ags" -name "*.js" -exec chmod +x {} \; 2>/dev/null; then
        print_warning "Failed to make some AGS scripts executable"
        failed_operations+=("AGS executable permissions")
    fi
    
    print_success "AGS configuration applied"
}

# Function to setup wallpaper engine
setup_wallpaper() {
    print_status "Setting up wallpaper engine..."
    
    backup_config "wallpaper"
    apply_config "$PROJECT_ROOT/wallpaper/config.json" "$CONFIG_DIR/wallpaper/config.json" || failed_operations+=("Wallpaper config")
    
    # Copy wallpaper picker script
    if ! cp "$PROJECT_ROOT/wallpaper/wallpaper-picker.py" "$HOME/.local/bin/wallpaper-picker" 2>/dev/null; then
        print_warning "Failed to copy wallpaper-picker script"
        failed_operations+=("Wallpaper picker script")
    else
        chmod +x "$HOME/.local/bin/wallpaper-picker" 2>/dev/null || {
            print_warning "Failed to make wallpaper-picker executable"
            failed_operations+=("Wallpaper picker permissions")
        }
    fi
    
    # Create default wallpaper directory structure
    mkdir -p "$HOME/Documents/Wallpapers/Images" 2>/dev/null || {
        print_warning "Failed to create wallpaper directories"
        failed_operations+=("Wallpaper directories")
    }
    mkdir -p "$HOME/Documents/Wallpapers/Videos" 2>/dev/null
    
    # Create default wallpaper (if not exists)
    if [ ! -f "$HOME/Documents/Wallpapers/macos-tahoe-default.jpg" ]; then
        # Create a simple gradient wallpaper
        if ! convert -size 1920x1080 gradient:'#667eea'-'#764ba2' \
            "$HOME/Documents/Wallpapers/macos-tahoe-default.jpg" 2>/dev/null; then
            # Fallback: download a wallpaper
            curl -s "https://picsum.photos/1920/1080" \
                -o "$HOME/Documents/Wallpapers/macos-tahoe-default.jpg" 2>/dev/null || {
                print_warning "Failed to create default wallpaper"
                failed_operations+=("Default wallpaper")
            }
        fi
    fi
    
    print_success "Wallpaper engine configured"
}

# Function to setup Wofi configuration
setup_wofi() {
    print_status "Setting up Wofi configuration..."
    
    backup_config "wofi"
    
    # Create Wofi config directory
    if ! mkdir -p "$CONFIG_DIR/wofi" 2>/dev/null; then
        print_warning "Failed to create Wofi config directory"
        failed_operations+=("Wofi directory")
        return 1
    fi
    
    # Create Wofi config
    if ! cat > "$CONFIG_DIR/wofi/config" 2>/dev/null << 'EOF'
# Wofi configuration for macOS Tahoe

# General settings
prompt = Run
normal_window = true
hide_scroll = false
allow_markup = true
parse_search = true
matching = multi-contains

# Appearance
width = 50%
height = 40%
xoffset = 0
yoffset = 0
location = center

# Colors
background = #ffffff
border = #cccccc
foreground = #1d1d1f
selected = #007AFF

# Fonts
font = SF Pro Display 14
EOF
    then
        print_warning "Failed to create Wofi config"
        failed_configs+=("wofi/config")
    fi
    
    # Create Wofi styles
    if ! cat > "$CONFIG_DIR/wofi/style.css" 2>/dev/null << 'EOF'
/* Wofi macOS Style */

* {
    font-family: 'SF Pro Display', 'San Francisco', sans-serif;
    font-size: 14px;
    color: #1d1d1f;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border: 1px solid rgba(0, 0, 0, 0.1);
    border-radius: 12px;
}

window {
    background: transparent;
    border: none;
}

box {
    margin: 12px;
}

entry {
    padding: 12px 16px;
    border: none;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
    border-radius: 8px 8px 0 0;
    background: rgba(255, 255, 255, 0.8);
    font-size: 16px;
}

entry:focus {
    outline: 2px solid #007AFF;
    outline-offset: -2px;
}

list {
    background: transparent;
    border: none;
}

row {
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    margin: 2px 0;
}

row:selected {
    background: #007AFF;
    color: white;
}

row:hover {
    background: rgba(0, 122, 255, 0.1);
}

row:selected:hover {
    background: #007AFF;
}
EOF
    then
        print_warning "Failed to create Wofi style"
        failed_configs+=("wofi/style.css")
    fi
    
    print_success "Wofi configuration applied"
}

# Function to setup notification daemon
setup_notifications() {
    print_status "Setting up notification daemon..."
    
    backup_config "dunst"
    
    # Create Dunst config
    if ! cat > "$CONFIG_DIR/dunst/dunstrc" 2>/dev/null << 'EOF'
# Dunst configuration for macOS Tahoe

[global]
    monitor = 0
    follow = mouse
    geometry = "300x80-20+60"
    indicate_hidden = yes
    shrink = no
    transparency = 10
    notification_height = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    frame_width = 1
    frame_color = "#cccccc"
    separator_color = frame
    sort = yes
    idle_threshold = 120
    font = SF Pro Display 13
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    show_age_threshold = 60
    word_wrap = yes
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    min_icon_size = 32
    max_icon_size = 128
    sticky_history = yes
    history_length = 20
    show_history = yes
    browser = /usr/bin/firefox -new-tab %s
    always_run_script = true
    title = Dunst
    class = Dunst
    startup_notification = false
    verbosity = mesg
    corner_radius = 12
    ignore_dbusclose = false
    force_xwayland = false

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period

[urgency_low]
    background = "#ffffff"
    foreground = "#1d1d1f"
    timeout = 10

[urgency_normal]
    background = "#ffffff"
    foreground = "#1d1d1f"
    timeout = 10

[urgency_critical]
    background = "#ff6b6b"
    foreground = "#ffffff"
    timeout = 0
EOF
    then
        print_warning "Failed to create Dunst config"
        failed_configs+=("dunst/dunstrc")
    fi
    
    print_success "Notification daemon configured"
}

# Function to setup terminal configuration
setup_terminal() {
    print_status "Setting up terminal configuration..."
    
    # Alacritty config
    if command -v alacritty &> /dev/null; then
        backup_config "alacritty"
        
        if ! mkdir -p "$CONFIG_DIR/alacritty" 2>/dev/null; then
            print_warning "Failed to create Alacritty config directory"
            failed_operations+=("Alacritty directory")
            return 1
        fi
        
        if ! cat > "$CONFIG_DIR/alacritty/alacritty.yml" 2>/dev/null << 'EOF'
# Alacritty configuration for macOS Tahoe

import:
  - /usr/share/alacritty/themes/macos.yml

env:
  TERM: xterm-256color
  LANG: en_US.UTF-8

window:
  dimensions:
    columns: 120
    lines: 30
  padding:
    x: 8
    y: 8
  decorations: none
  startup_mode: Windowed
  title: Alacritty
  class:
    instance: Alacritty
    general: Alacritty
  opacity: 0.95
  blur: true

scrolling:
  history: 10000
  multiplier: 3
  faux_multiplier: 3
  auto_scroll: false

font:
  normal:
    family: SF Mono
    style: Regular
  bold:
    family: SF Mono
    style: Bold
  italic:
    family: SF Mono
    style: Italic
  bold_italic:
    family: SF Mono
    style: Bold Italic
  size: 12.0
  offset:
    x: 0
    y: 0
  glyph_offset:
    x: 0
    y: 0

draw_bold_text_with_bright_colors: true
colors:
  primary:
    background: '#1e1e1e'
    foreground: '#d4d4d4'

cursor:
  style: Block
  vi_mode_style: None
  unfocused_hollow: true
  thickness: 0.15

background_opacity: 0.95

selection:
  semantic_escape_chars: ",│`|:$'
  save_to_clipboard: false

live_config_reload: true

shell:
  program: /bin/zsh
  args:
    - -l
    - -c
    - "zsh"

key_bindings:
  - { key: V,        mods: Control|Shift, action: Paste                      }
  - { key: C,        mods: Control|Shift, action: Copy                       }
  - { key: Q,        mods: Command,       action: Quit                       }
  - { key: W,        mods: Command,       action: Quit                       }
  - { key: N,        mods: Command,       action: SpawnNewInstance           }
  - { key: F,        mods: Command|Control, action: ToggleFullscreen         }
  - { key: Equals,   mods: Command,       action: IncreaseFontSize           }
  - { key: Plus,     mods: Command,       action: IncreaseFontSize           }
  - { key: Minus,    mods: Command,       action: DecreaseFontSize           }
  - { key: K,        mods: Command,       action: ClearHistory               }
  - { key: Home,     mods: Command,       action: ScrollToTop                }
  - { key: End,      mods: Command,       action: ScrollToBottom             }
EOF
        then
            print_warning "Failed to create Alacritty config"
            failed_configs+=("alacritty/alacritty.yml")
        fi
    fi
    
    print_success "Terminal configuration applied"
}

# Function to create desktop entries
create_desktop_entries() {
    print_status "Creating desktop entries..."
    
    # Wallpaper picker desktop entry
    if ! cat > "$HOME/.local/share/applications/wallpaper-picker.desktop" 2>/dev/null << 'EOF'
[Desktop Entry]
Name=Wallpaper Picker
Comment=Choose and manage desktop wallpapers
Exec=/home/%u/.local/bin/wallpaper-picker
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=System;Settings;
Keywords=wallpaper;background;desktop;
EOF
    then
        print_warning "Failed to create desktop entry"
        failed_configs+=("wallpaper-picker.desktop")
    fi
    
    print_success "Desktop entries created"
}

# Function to setup shell configuration
setup_shell() {
    print_status "Setting up shell configuration..."
    
    # Zsh configuration
    if [ -f "$HOME/.zshrc" ]; then
        if ! cp "$HOME/.zshrc" "${BACKUP_DIR}/zshrc_backup" 2>/dev/null; then
            print_warning "Failed to backup .zshrc"
            failed_operations+=("Backup .zshrc")
        fi
    fi
    
    if ! cat >> "$HOME/.zshrc" 2>/dev/null << 'EOF'

# macOS Tahoe Shell Configuration
export GTK_THEME=macOS-Tahoe
export ICON_THEME=macOS-Tahoe
export CURSOR_THEME=macOS
export FONT_NAME="SF Pro Display 11"

# Hyprland environment
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1

# Aliases for macOS-like commands
alias finder='nautilus'
alias trash='gio trash'
alias ql='xdg-open'  # Quick Look
alias lock='hyprlock'
alias mission-control='hyprctl dispatch overview:toggle'

# Utility functions
wallpaper() {
    ~/.local/bin/wallpaper-picker &
}

system-preferences() {
    gnome-control-center &
}

# macOS-style prompt
PROMPT='%F{blue}%n%f at %F{green}%m%f in %F{yellow}%~%f $(git_prompt_info) $ '
EOF
    then
        print_warning "Failed to update .zshrc"
        failed_configs+=(".zshrc")
    fi
    
    print_success "Shell configuration applied"
}

# Function to setup autostart
setup_autostart() {
    print_status "Setting up autostart applications..."
    
    if ! mkdir -p "$HOME/.config/autostart" 2>/dev/null; then
        print_warning "Failed to create autostart directory"
        failed_operations+=("Autostart directory")
        return 1
    fi
    
    # Hyprland autostart
    if ! cat > "$HOME/.config/autostart/hyprland.desktop" 2>/dev/null << 'EOF'
[Desktop Entry]
Type=Application
Name=Hyprland Services
Comment=Start Hyprland services
Exec=/home/%u/.config/hypr/autostart.sh
X-GNOME-Autostart-Phase=Initialization
X-GNOME-Autostart-Notify=true
EOF
    then
        print_warning "Failed to create autostart desktop entry"
        failed_configs+=("hyprland.desktop")
    fi
    
    # Create autostart script
    if ! cat > "$CONFIG_DIR/hypr/autostart.sh" 2>/dev/null << 'EOF'
#!/bin/bash

# Hyprland autostart script for macOS Tahoe

# Start wallpaper engine
swww init &
swww img ~/Documents/Wallpapers/macos-tahoe-default.jpg &

# Start waybar
waybar &

# Start AGS widgets
ags &

# Start notification daemon
dunst &

# Start polkit agent
/usr/lib/polkit-kde-authentication-agent-1 &

# Start network applet
nm-applet --indicator &

# Start bluetooth applet
blueman-applet &

# Start clipboard manager
wl-paste --type text --watch wl-copy --clear --type text &
wl-paste --type image --watch wl-copy --clear --type image &

# Start screen locker
hypridle &

# Wait for all processes
wait
EOF
    then
        print_warning "Failed to create autostart script"
        failed_configs+=("autostart.sh")
    else
        if ! chmod +x "$CONFIG_DIR/hypr/autostart.sh" 2>/dev/null; then
            print_warning "Failed to make autostart script executable"
            failed_operations+=("Autostart script permissions")
        fi
    fi
    
    print_success "Autostart applications configured"
}

# Function to create default wallpapers
create_default_wallpapers() {
    print_status "Creating default wallpapers..."
    
    # macOS-style gradient wallpapers
    wallpapers=(
        "macos-tahoe-blue.jpg:#667eea:#764ba2"
        "macos-tahoe-purple.jpg:#f093fb:#f5576c"
        "macos-tahoe-green.jpg:#4facfe:#00f2fe"
        "macos-tahoe-orange.jpg:#fa709a:#fee140"
        "macos-tahoe-dark.jpg:#2c3e50:#34495e"
    )
    
    for wallpaper in "${wallpapers[@]}"; do
        IFS=':' read -r filename start_color end_color <<< "$wallpaper"
        
        if [ ! -f "$HOME/Documents/Wallpapers/$filename" ]; then
            if command -v convert &> /dev/null; then
                if ! convert -size 1920x1080 gradient:"$start_color":"$end_color" \
                    "$HOME/Documents/Wallpapers/$filename" 2>/dev/null; then
                    print_warning "Failed to create wallpaper: $filename"
                    failed_operations+=("Wallpaper: $filename")
                fi
            else
                print_warning "ImageMagick not installed, skipping wallpaper generation"
                failed_operations+=("Wallpaper generation")
                break
            fi
        fi
    done
    
    print_success "Default wallpapers created"
}

# Function to setup keyboard shortcuts
setup_shortcuts() {
    print_status "Setting up keyboard shortcuts..."
    
    # Create shortcuts file for display managers
    if ! cat > "$HOME/.local/share/applications/shortcuts.conf" 2>/dev/null << 'EOF'
# macOS Tahoe Keyboard Shortcuts

# Window Management
Super+Q         Launch application menu
Super+Space     Run command
Super+Return    Terminal
Super+N         File manager
Super+T         Alternative file manager
Super+W         Close window
Super+M         Toggle fullscreen
Super+F         Toggle floating
Super+Tab       Switch to next window
Super+Shift+Tab Switch to previous window

# Workspaces
Super+1..0      Switch to workspace 1-10
Super+Shift+1..0 Move window to workspace 1-10
Super+S         Toggle special workspace

# Applications
Super+E         File manager
Super+C         Code editor
Super+B         Web browser
Super+P         Power menu

# System
Super+L         Lock screen
Super+Escape    Power menu
Super+Shift+Escape Exit Hyprland

# Screenshots
Super+Print     Screenshot entire screen
Super+Shift+Print Screenshot active window
Super+Ctrl+Print Screenshot selected area

# Media
XF86AudioRaiseVolume  Increase volume
XF86AudioLowerVolume  Decrease volume
XF86AudioMute         Toggle mute
XF86AudioPlay         Play/Pause
XF86AudioNext         Next track
XF86AudioPrev         Previous track
XF86MonBrightnessUp   Increase brightness
XF86MonBrightnessDown Decrease brightness
EOF
    then
        print_warning "Failed to create shortcuts file"
        failed_configs+=("shortcuts.conf")
    fi
    
    print_success "Keyboard shortcuts configured"
}

# Function to print completion message
print_completion() {
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    # Display summary
    if [ ${#failed_configs[@]} -eq 0 ] && [ ${#failed_operations[@]} -eq 0 ]; then
        print_success "✓✓✓ Setup completed successfully! ✓✓✓"
    else
        print_warning "Setup completed with some issues:"
        echo
        
        if [ ${#failed_operations[@]} -gt 0 ]; then
            echo -e "${YELLOW}Operations with issues:${NC}"
            for op in "${failed_operations[@]}"; do
                echo -e "  ${RED}✗${NC} $op"
            done
            echo
        fi
        
        if [ ${#failed_configs[@]} -gt 0 ]; then
            echo -e "${YELLOW}Configuration files that failed:${NC}"
            for cfg in "${failed_configs[@]}"; do
                echo -e "  ${RED}✗${NC} $cfg"
            done
            echo
        fi
        
        echo -e "${YELLOW}Note: You can manually configure failed items later.${NC}"
        echo -e "${YELLOW}Most configurations are optional.${NC}"
        echo
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  macOS Tahoe on Arch Linux - Setup Complete${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "1. Apply theme with: ${GREEN}./theme.sh${NC}"
    echo -e "2. Reboot your system"
    echo -e "3. Select Hyprland from your display manager"
    echo -e "4. Run ${GREEN}wallpaper-picker${NC} to choose wallpapers"
    echo
    echo -e "${YELLOW}Important Files:${NC}"
    echo -e "- Main config: ${GREEN}$CONFIG_DIR/hypr/hyprland.conf${NC}"
    echo -e "- Waybar config: ${GREEN}$CONFIG_DIR/waybar${NC}"
    echo -e "- AGS widgets: ${GREEN}$CONFIG_DIR/ags${NC}"
    echo -e "- Wallpapers: ${GREEN}$HOME/Documents/Wallpapers${NC}"
    echo -e "- Scripts: ${GREEN}$HOME/.local/bin${NC}"
    echo
    echo -e "${YELLOW}Configuration Backup:${NC}"
    echo -e "Your original configurations are backed up in: ${GREEN}$BACKUP_DIR${NC}"
    echo
    echo -e "${YELLOW}Key Bindings:${NC}"
    echo -e "- Super+Q: Application launcher"
    echo -e "- Super+Space: Command runner"
    echo -e "- Super+Return: Terminal"
    echo -e "- Super+W: Close window"
    echo -e "- Super+M: Toggle fullscreen"
    echo -e "- Super+Tab: Window switcher"
    echo -e "- Super+L: Lock screen"
    echo -e "- Super+Print: Screenshot"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

# Main setup function
main() {
    print_status "Starting macOS Tahoe setup..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_error "Run as regular user with sudo privileges."
        exit 1
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Perform setup steps
    create_directories
    setup_hyprland
    setup_waybar
    setup_ags
    setup_wallpaper
    setup_wofi
    setup_notifications
    setup_terminal
    create_desktop_entries
    setup_shell
    setup_autostart
    create_default_wallpapers
    setup_shortcuts
    
    # Apply theme (if theme.sh exists)
    if [ -f "$SCRIPT_DIR/theme.sh" ]; then
        print_status "Would you like to apply the macOS theme now?"
        read -p "Run theme.sh? (y/N): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            "$SCRIPT_DIR/theme.sh"
        fi
    fi
    
    print_completion
}

# Run main function
main "$@"