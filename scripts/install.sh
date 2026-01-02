#!/bin/bash

# macOS Tahoe on Arch Linux - Installation Script
# Comprehensive setup for pixel-perfect macOS replica

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

# Function to check if running on Arch Linux
check_arch_linux() {
    if [ ! -f /etc/arch-release ]; then
        print_error "This script is designed for Arch Linux only!"
        exit 1
    fi
}

# Function to backup existing configurations
backup_configs() {
    print_status "Backing up existing configurations..."
    mkdir -p "$BACKUP_DIR"
    
    local configs=("hypr" "ags" "waybar" "wofi" "gtk-3.0" "gtk-4.0")
    
    for config in "${configs[@]}"; do
        if [ -d "$CONFIG_DIR/$config" ]; then
            cp -r "$CONFIG_DIR/$config" "$BACKUP_DIR/"
            print_status "Backed up $config to $BACKUP_DIR"
        fi
    done
    
    print_success "Configuration backup completed"
}

# Function to install base dependencies
install_base_deps() {
    print_status "Installing base dependencies..."
    
    sudo pacman -Syu --noconfirm
    
    # Base development tools
    sudo pacman -S --needed --noconfirm \
        base-devel \
        git \
        curl \
        wget \
        unzip \
        zip \
        cmake \
        meson \
        ninja \
        gcc \
        pkg-config
    
    # Wayland and Hyprland dependencies
    sudo pacman -S --needed --noconfirm \
        wayland \
        wayland-protocols \
        libdrm \
        libxkbcommon \
        pixman \
        cairo \
        pango \
        gdk-pixbuf2 \
        librsvg \
        glib2
    
    # Graphics and rendering
    sudo pacman -S --needed --noconfirm \
        mesa \
        libglvnd
    
    # Audio and multimedia
    sudo pacman -S --needed --noconfirm \
        pipewire \
        pipewire-alsa \
        pipewire-pulse \
        wireplumber \
        pavucontrol \
        alsa-utils \
        ffmpeg \
        ffmpegthumbnailer \
        gst-plugins-base \
        gst-plugins-good \
        gst-plugins-bad \
        gst-plugins-ugly
    
    # Fonts and theming
    sudo pacman -S --needed --noconfirm \
        ttf-dejavu \
        ttf-liberation \
        ttf-roboto \
        ttf-opensans \
        ttf-font-awesome \
        noto-fonts \
        noto-fonts-emoji \
        adwaita-icon-theme \
        hicolor-icon-theme \
        gtk3 \
        gtk4 \
        libadwaita
    
    print_success "Base dependencies installed"
}

# Function to install Hyprland
install_hyprland() {
    print_status "Installing Hyprland..."
    
    # Install Hyprland from official repos
    sudo pacman -S --needed --noconfirm hyprland hyprpaper hyprpicker hyprlock hypridle
    
    # Install additional Hyprland utilities
    sudo pacman -S --needed --noconfirm \
        grim \
        slurp \
        wl-clipboard
    
    print_success "Hyprland installed"
}

# Function to install AUR helper (yay)
install_aur_helper() {
    print_status "Installing AUR helper (yay)..."
    
    if ! command -v yay &> /dev/null; then
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        print_success "yay installed"
    else
        print_status "yay is already installed"
    fi
}

# Function to install AUR packages
install_aur_packages() {
    print_status "Installing AUR packages..."
    
    # Install essential AUR packages
    yay -S --needed --noconfirm \
        swww \
        grimblast-git 2>/dev/null || print_warning "grimblast-git failed to install"
    
    print_success "AUR packages installed"
}

# Function to install AGS (Advanced Gtk+ Sequencer)
install_ags() {
    print_status "Installing AGS (Advanced Gtk+ Sequencer)..."
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm \
        gobject-introspection \
        vala \
        libgee \
        json-glib \
        libxml2 \
        libsoup3 \
        gstreamer \
        gst-plugins-base \
        gtk3 \
        gtk4 \
        libadwaita
    
    # Install AGS from AUR
    yay -S --needed --noconfirm ags-git
    
    print_success "AGS installed"
}

# Function to install Fabric (alternative to AGS)
install_fabric() {
    print_status "Installing Fabric..."
    
    # Fabric is a modern widget toolkit (optional)
    yay -S --needed --noconfirm fabric-git 2>/dev/null || print_warning "Fabric installation skipped"
    
    print_success "Fabric installation attempted"
}

# Function to install application launchers
install_launchers() {
    print_status "Installing application launchers..."
    
    # Wofi (primary launcher)
    sudo pacman -S --needed --noconfirm wofi
    
    # Additional launchers (optional)
    print_status "Installing optional wofi extensions..."
    yay -S --needed --noconfirm wofi-emoji 2>/dev/null || print_warning "Optional wofi extensions skipped"
    
    print_success "Launchers installed"
}

# Function to install file managers
install_file_managers() {
    print_status "Installing file managers..."
    
    # Nautilus (GNOME file manager)
    sudo pacman -S --needed --noconfirm \
        nautilus \
        file-roller \
        gvfs \
        gvfs-mtp \
        gvfs-afc \
        gvfs-gphoto2 \
        gvfs-nfs \
        gvfs-smb
    
    # Thunar (XFCE file manager) - alternative
    sudo pacman -S --needed --noconfirm \
        thunar \
        thunar-archive-plugin \
        thunar-media-tags-plugin \
        tumbler
    
    print_success "File managers installed"
}

# Function to install terminal and development tools
install_terminal_tools() {
    print_status "Installing terminal and development tools..."
    
    # Terminal emulators
    sudo pacman -S --needed --noconfirm \
        alacritty \
        kitty \
        foot
    
    # Shell and tools
    sudo pacman -S --needed --noconfirm \
        zsh \
        fish \
        starship \
        eza \
        bat \
        fd \
        ripgrep \
        fzf \
        tmux \
        neovim
    
    # Development tools (optional)
    sudo pacman -S --needed --noconfirm \
        rustup \
        go 2>/dev/null || print_warning "Some dev tools skipped"
    
    print_success "Terminal and development tools installed"
}

# Function to install macOS theme components
install_macos_theme() {
    print_status "Installing macOS theme components..."
    
    # Install macOS themes from AUR
    yay -S --needed --noconfirm \
        macos-sierra-gtk-theme-git \
        macos-sierra-icon-theme-git \
        macos-cursors-git \
        macos-wallpapers-git \
        san-francisco-pro-fonts-git \
        sf-mono-fonts-git \
        sf-pro-fonts-git
    
    # Install additional theming tools
    sudo pacman -S --needed --noconfirm \
        lxappearance \
        qt5ct \
        qt6ct \
        kvantum
    
    print_success "macOS theme components installed"
}

# Function to install wallpaper engine dependencies
install_wallpaper_deps() {
    print_status "Installing wallpaper engine dependencies..."
    
    # Video wallpaper dependencies
    sudo pacman -S --needed --noconfirm \
        mpv \
        ffmpeg \
        ffmpegthumbnailer \
        libmpv
    
    # Image wallpaper dependencies
    sudo pacman -S --needed --noconfirm \
        imagemagick \
        feh
    
    # Install wallpaper engines from AUR
    yay -S --needed --noconfirm \
        swww 2>/dev/null || print_warning "swww installation skipped"
    
    print_success "Wallpaper engine dependencies installed"
}

# Function to install utility applications
install_utility_apps() {
    print_status "Installing utility applications..."
    
    # System utilities
    sudo pacman -S --needed --noconfirm \
        neofetch \
        htop \
        btop
    
    # Network utilities
    sudo pacman -S --needed --noconfirm \
        networkmanager \
        nm-connection-editor \
        blueman \
        bluez \
        bluez-utils \
        openssh
    
    # Media utilities (optional)
    sudo pacman -S --needed --noconfirm \
        mpv \
        gimp 2>/dev/null || print_warning "Some media apps skipped"
    
    # Office and productivity (optional)
    sudo pacman -S --needed --noconfirm \
        firefox 2>/dev/null || print_warning "Some productivity apps skipped"
    
    # Install additional utilities from AUR (optional)
    print_status "Installing optional AUR utilities..."
    yay -S --needed --noconfirm visual-studio-code-bin 2>/dev/null || print_warning "VS Code skipped"
    yay -S --needed --noconfirm spotify 2>/dev/null || print_warning "Spotify skipped"
    
    print_success "Utility applications installed"
}

# Function to create user directories
create_user_dirs() {
    print_status "Creating user directories..."
    
    # Create standard XDG directories
    xdg-user-dirs-update
    
    # Create project-specific directories
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/ags"
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/wofi"
    mkdir -p "$HOME/.config/wallpaper"
    mkdir -p "$HOME/.config/gSlapper"
    mkdir -p "$HOME/.config/swww"
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/Documents/Wallpapers"
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Development"
    
    print_success "User directories created"
}

# Function to install fonts
install_fonts() {
    print_status "Installing additional fonts..."
    
    # Install nerd fonts for icons (selected fonts only)
    yay -S --needed --noconfirm \
        ttf-meslo-nerd 2>/dev/null || print_warning "Nerd fonts skipped"
    
    yay -S --needed --noconfirm \
        ttf-jetbrains-mono-nerd 2>/dev/null || print_warning "JetBrains Mono Nerd skipped"
    
    # Install emoji fonts
    sudo pacman -S --needed --noconfirm \
        noto-fonts-emoji
    
    # Update font cache
    fc-cache -fv
    
    print_success "Fonts installed and cached"
}

# Function to enable system services
enable_services() {
    print_status "Enabling system services..."
    
    # NetworkManager
    sudo systemctl enable NetworkManager.service
    sudo systemctl start NetworkManager.service
    
    # Bluetooth
    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service
    
    # PipeWire
    systemctl --user enable pipewire.service
    systemctl --user start pipewire.service
    
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire-pulse.service
    
    systemctl --user enable wireplumber.service
    systemctl --user start wireplumber.service
    
    # SSH
    sudo systemctl enable sshd.service
    
    print_success "System services enabled"
}

# Function to clone and setup repositories
setup_repositories() {
    print_status "Setting up additional repositories..."
    
    cd "$HOME/Development"
    
    # Clone macOS theme repositories
    if [ ! -d "macos-sierra-gtk-theme" ]; then
        git clone https://github.com/vinceliuice/macos-sierra-gtk-theme.git
    fi
    
    if [ ! -d "macOS-San-Francisco-Font" ]; then
        git clone https://github.com/AppleDesignResources/SanFranciscoFont.git macOS-San-Francisco-Font
    fi
    
    # Clone Hyprland configurations
    if [ ! -d "hyprland-macos-config" ]; then
        git clone https://github.com/prasanthrangan/hyprdots.git hyprland-macos-config
    fi
    
    # Clone AGS widget examples
    if [ ! -d "ags-widgets" ]; then
        git clone https://github.com/Aylur/ags-widgets.git
    fi
    
    print_success "Repositories cloned"
}

# Function to set permissions
set_permissions() {
    print_status "Setting file permissions..."
    
    # Make scripts executable
    chmod +x "$PROJECT_ROOT/scripts/"*.sh
    chmod +x "$HOME/.local/bin/"* 2>/dev/null || true
    
    # Set user ownership
    sudo chown -R "$USER:$USER" "$CONFIG_DIR"
    sudo chown -R "$USER:$USER" "$HOME/.local"
    
    print_success "Permissions set"
}

# Function to print completion message
print_completion() {
    print_success "Installation completed successfully!"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  macOS Tahoe on Arch Linux - Installation Complete${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "1. Run: ${GREEN}./setup.sh${NC} to apply configurations"
    echo -e "2. Run: ${GREEN}./theme.sh${NC} to apply macOS theme"
    echo -e "3. Reboot your system"
    echo -e "4. Select Hyprland from your display manager"
    echo
    echo -e "${YELLOW}Configuration Backup:${NC}"
    echo -e "Your original configurations are backed up in: ${GREEN}$BACKUP_DIR${NC}"
    echo
    echo -e "${YELLOW}Important Files:${NC}"
    echo -e "- Configurations: ${GREEN}$CONFIG_DIR${NC}"
    echo -e "- Scripts: ${GREEN}$PROJECT_ROOT/scripts${NC}"
    echo -e "- Wallpapers: ${GREEN}$HOME/Documents/Wallpapers${NC}"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

# Main installation function
main() {
    print_status "Starting macOS Tahoe installation for Arch Linux..."
    
    # Check if running as root for system-wide installations
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_error "Run as regular user with sudo privileges."
        exit 1
    fi
    
    # Check if sudo is available
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is not installed! Please install sudo first."
        exit 1
    fi
    
    # Check if running on Arch Linux
    check_arch_linux
    
    # Perform installation steps
    backup_configs
    install_base_deps
    install_hyprland
    install_aur_helper
    install_aur_packages
    install_ags
    install_launchers
    install_file_managers
    install_terminal_tools
    install_macos_theme
    install_wallpaper_deps
    install_utility_apps
    install_fonts
    create_user_dirs
    setup_repositories
    enable_services
    set_permissions
    
    print_completion
}

# Run main function
main "$@"