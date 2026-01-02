#!/bin/bash

# macOS Tahoe on Arch Linux - Uninstallation Script
# Clean removal of all components

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

# Function to confirm action
confirm_action() {
    local action="$1"
    local response
    
    echo -e "${YELLOW}Are you sure you want to $action?${NC}"
    echo -e "${YELLOW}This action cannot be undone.${NC}"
    read -p "Type 'yes' to confirm: " response
    
    if [[ "$response" != "yes" ]]; then
        print_status "Action cancelled."
        return 1
    fi
    
    return 0
}

# Function to backup current configurations
backup_current_configs() {
    print_status "Backing up current configurations..."
    
    mkdir -p "$BACKUP_DIR"
    
    local configs=(
        "hypr"
        "ags"
        "waybar"
        "wofi"
        "wallpaper"
        "gSlapper"
        "swww"
        "gtk-3.0"
        "gtk-4.0"
        "dconf"
        "Kvantum"
        "qt5ct"
        "qt6ct"
    )
    
    for config in "${configs[@]}"; do
        if [ -d "$CONFIG_DIR/$config" ]; then
            cp -r "$CONFIG_DIR/$config" "$BACKUP_DIR/"
            print_status "Backed up $config to $BACKUP_DIR"
        fi
    done
    
    # Backup user local files
    if [ -d "$HOME/.local/share/applications" ]; then
        cp -r "$HOME/.local/share/applications" "$BACKUP_DIR/"
    fi
    
    if [ -d "$HOME/.local/bin" ]; then
        cp -r "$HOME/.local/bin" "$BACKUP_DIR/"
    fi
    
    print_success "Current configurations backed up to $BACKUP_DIR"
}

# Function to remove configurations
remove_configurations() {
    print_status "Removing macOS Tahoe configurations..."
    
    local configs=(
        "hypr"
        "ags"
        "waybar"
        "wofi"
        "wallpaper"
        "gSlapper"
        "swww"
    )
    
    for config in "${configs[@]}"; do
        if [ -d "$CONFIG_DIR/$config" ]; then
            rm -rf "$CONFIG_DIR/$config"
            print_status "Removed $CONFIG_DIR/$config"
        fi
    done
    
    # Remove custom desktop entries
    if [ -d "$HOME/.local/share/applications" ]; then
        find "$HOME/.local/share/applications" -name "*macos*" -o -name "*tahoe*" -delete 2>/dev/null || true
        find "$HOME/.local/share/applications" -name "*hypr*" -delete 2>/dev/null || true
    fi
    
    # Remove custom scripts
    if [ -d "$HOME/.local/bin" ]; then
        find "$HOME/.local/bin" -name "*macos*" -o -name "*tahoe*" -delete 2>/dev/null || true
        find "$HOME/.local/bin" -name "*hypr*" -delete 2>/dev/null || true
    fi
    
    print_success "Configurations removed"
}

# Function to remove installed packages
remove_packages() {
    print_status "Removing macOS Tahoe packages..."
    
    # List of packages to remove (AUR packages first)
    local aur_packages=(
        "hyprland-git"
        "waybar-hyprland-git"
        "wofi-git"
        "swww"
        "gSlapper"
        "grimblast-git"
        "wl-clip-persist-git"
        "wlr-randr-git"
        "kanshi-git"
        "ags-git"
        "fabric-git"
        "wofi-power-menu"
        "wofi-emoji"
        "wofi-calc"
        "wofi-pass"
        "macos-sierra-gtk-theme-git"
        "macos-sierra-icon-theme-git"
        "macos-cursors-git"
        "macos-wallpapers-git"
        "san-francisco-pro-fonts-git"
        "sf-mono-fonts-git"
        "sf-pro-fonts-git"
        "nerd-fonts-complete"
        "ttf-meslo-nerd-font-powerlevel10k"
        "ttf-fira-code"
        "ttf-jetbrains-mono"
        "ttf-cascadia-code"
        "ttf-hack"
        "ttf-iosevka-nerd"
        "visual-studio-code-bin"
        "discord"
        "slack-desktop"
        "spotify"
        "teamspeak3"
        "steam"
        "onlyoffice-bin"
        "brightnessctl"
        "gtk-engine-murrine"
        "gtk-engines"
        "sassc"
        "optipng"
        "inkscape"
        "imagemagick"
        "librsvg"
    )
    
    # Remove AUR packages
    for package in "${aur_packages[@]}"; do
        if yay -Qi "$package" &>/dev/null; then
            yay -Rns --noconfirm "$package" 2>/dev/null || true
            print_status "Removed AUR package: $package"
        fi
    done
    
    # List of official packages to remove (optional)
    local official_packages=(
        "hyprland"
        "hyprpaper"
        "hyprpicker"
        "hyprlock"
        "hypridle"
        "grimblast"
        "slurp"
        "wl-clipboard"
        "wl-clip-persist"
        "wlr-randr"
        "wlsunset"
        "kanshi"
        "wofi"
        "nautilus"
        "nautilus-open-any-terminal"
        "file-roller"
        "thunar"
        "thunar-archive-plugin"
        "thunar-media-tags-plugin"
        "thunar-vcs-plugin"
        "tumbler"
        "tumbler-plugins-extra"
        "alacritty"
        "kitty"
        "foot"
        "wezterm"
        "zsh"
        "fish"
        "starship"
        "eza"
        "bat"
        "fd"
        "ripgrep"
        "fzf"
        "tmux"
        "neovim"
        "helix"
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse"
        "wireplumber"
        "pavucontrol"
        "alsa-utils"
        "ffmpeg"
        "ffmpegthumbnailer"
        "mpv"
        "feh"
        "sxiv"
        "nsxiv"
        "code"
        "intellij-idea-community-edition"
        "libreoffice-fresh"
        "thunderbird"
        "firefox"
        "chromium"
        "vlc"
        "obs-studio"
        "kdenlive"
        "gimp"
        "inkscape"
        "krita"
        "networkmanager"
        "nm-connection-editor"
        "blueman"
        "bluez"
        "bluez-utils"
        "polkit-kde-agent"
        "xdg-desktop-portal-hyprland"
        "xdg-desktop-portal-gtk"
        "xdg-desktop-portal-wlr"
        "neofetch"
        "htop"
        "btop"
        "iotop"
        "nethogs"
        "vnstat"
        "lm_sensors"
        "hwinfo"
        "inxi"
        "lshw"
    )
    
    print_warning "Official packages are kept to avoid breaking your system"
    print_warning "You can remove them manually if needed"
    
    print_success "Package removal completed"
}

# Function to remove theme configurations
remove_theme_configs() {
    print_status "Removing theme configurations..."
    
    # Remove GTK configurations
    if [ -f "$HOME/.gtkrc-2.0" ]; then
        rm "$HOME/.gtkrc-2.0"
        print_status "Removed .gtkrc-2.0"
    fi
    
    # Remove GTK3/4 settings
    if [ -d "$CONFIG_DIR/gtk-3.0" ]; then
        rm -rf "$CONFIG_DIR/gtk-3.0"
        print_status "Removed gtk-3.0 config"
    fi
    
    if [ -d "$CONFIG_DIR/gtk-4.0" ]; then
        rm -rf "$CONFIG_DIR/gtk-4.0"
        print_status "Removed gtk-4.0 config"
    fi
    
    # Remove dconf settings
    if command -v dconf &> /dev/null; then
        dconf reset -f /org/gnome/desktop/interface/
        dconf reset -f /org/gnome/desktop/wm/preferences/
        print_status "Reset dconf settings"
    fi
    
    # Remove Kvantum theme
    if [ -d "$CONFIG_DIR/Kvantum" ]; then
        rm -rf "$CONFIG_DIR/Kvantum"
        print_status "Removed Kvantum config"
    fi
    
    # Remove Qt configurations
    if [ -d "$CONFIG_DIR/qt5ct" ]; then
        rm -rf "$CONFIG_DIR/qt5ct"
        print_status "Removed qt5ct config"
    fi
    
    if [ -d "$CONFIG_DIR/qt6ct" ]; then
        rm -rf "$CONFIG_DIR/qt6ct"
        print_status "Removed qt6ct config"
    fi
    
    print_success "Theme configurations removed"
}

# Function to remove development repositories
remove_repositories() {
    print_status "Removing development repositories..."
    
    local repos=(
        "$HOME/Development/macos-sierra-gtk-theme"
        "$HOME/Development/macOS-San-Francisco-Font"
        "$HOME/Development/hyprland-macos-config"
        "$HOME/Development/ags-widgets"
    )
    
    for repo in "${repos[@]}"; do
        if [ -d "$repo" ]; then
            rm -rf "$repo"
            print_status "Removed repository: $repo"
        fi
    done
    
    print_success "Development repositories removed"
}

# Function to clean cache
clean_cache() {
    print_status "Cleaning package cache..."
    
    # Clean yay cache
    if [ -d "$HOME/.cache/yay" ]; then
        rm -rf "$HOME/.cache/yay"
        print_status "Cleaned yay cache"
    fi
    
    # Clean pacman cache (optional)
    if confirm_action "clean pacman package cache (this will remove downloaded packages)"; then
        sudo pacman -Scc --noconfirm
        print_status "Cleaned pacman cache"
    fi
    
    # Clean thumbnail cache
    if [ -d "$HOME/.cache/thumbnails" ]; then
        rm -rf "$HOME/.cache/thumbnails"
        print_status "Cleaned thumbnail cache"
    fi
    
    print_success "Cache cleaned"
}

# Function to stop and disable services
disable_services() {
    print_status "Disabling services..."
    
    # User services
    systemctl --user stop pipewire.service 2>/dev/null || true
    systemctl --user disable pipewire.service 2>/dev/null || true
    
    systemctl --user stop pipewire-pulse.service 2>/dev/null || true
    systemctl --user disable pipewire-pulse.service 2>/dev/null || true
    
    systemctl --user stop wireplumber.service 2>/dev/null || true
    systemctl --user disable wireplumber.service 2>/dev/null || true
    
    print_success "Services disabled"
}

# Function to print completion message
print_completion() {
    print_success "Uninstallation completed!"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  macOS Tahoe - Uninstallation Complete${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${YELLOW}Important Notes:${NC}"
    echo -e "- Your original configurations are backed up in: ${GREEN}$BACKUP_DIR${NC}"
    echo -e "- Some official packages were kept to avoid breaking your system"
    echo -e "- You can manually remove remaining packages if needed"
    echo -e "- Consider rebooting your system to complete the cleanup"
    echo
    echo -e "${YELLOW}To restore your previous configuration:${NC}"
    echo -e "cp -r $BACKUP_DIR/* $CONFIG_DIR/"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

# Main uninstall function
main() {
    print_status "Starting macOS Tahoe uninstallation..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        exit 1
    fi
    
    # Confirm uninstallation
    if ! confirm_action "completely uninstall macOS Tahoe"; then
        print_status "Uninstallation cancelled."
        exit 0
    fi
    
    # Perform uninstallation steps
    backup_current_configs
    
    if confirm_action "remove all configuration files"; then
        remove_configurations
    fi
    
    if confirm_action "remove installed packages"; then
        remove_packages
    fi
    
    if confirm_action "remove theme configurations"; then
        remove_theme_configs
    fi
    
    if confirm_action "remove development repositories"; then
        remove_repositories
    fi
    
    if confirm_action "clean package cache"; then
        clean_cache
    fi
    
    disable_services
    
    print_completion
}

# Run main function
main "$@"