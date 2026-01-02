#!/bin/bash

# macOS Tahoe on Arch Linux - Installation Script
# Comprehensive setup for pixel-perfect macOS replica

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

# Arrays to track failed installations
failed_packages=()
failed_groups=()
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
    
    if ! sudo pacman -Syu --noconfirm 2>/dev/null; then
        print_warning "System update had issues, continuing..."
        failed_operations+=("System update")
    fi
    
    # Base development tools
    if ! sudo pacman -S --needed --noconfirm \
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
        pkg-config 2>/dev/null; then
        print_warning "Some base development tools failed to install"
        failed_groups+=("Base development tools")
    fi
    
    # Wayland and Hyprland dependencies
    if ! sudo pacman -S --needed --noconfirm \
        wayland \
        wayland-protocols \
        libdrm \
        libxkbcommon \
        pixman \
        cairo \
        pango \
        gdk-pixbuf2 \
        librsvg \
        glib2 2>/dev/null; then
        print_warning "Some Wayland dependencies failed to install"
        failed_groups+=("Wayland dependencies")
    fi
    
    # Graphics and rendering
    if ! sudo pacman -S --needed --noconfirm \
        mesa \
        libglvnd 2>/dev/null; then
        print_warning "Some graphics libraries failed to install"
        failed_groups+=("Graphics libraries")
    fi
    
    # Audio and multimedia
    if ! sudo pacman -S --needed --noconfirm \
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
        gst-plugins-ugly 2>/dev/null; then
        print_warning "Some audio/multimedia packages failed to install"
        failed_groups+=("Audio/multimedia")
    fi
    
    # Fonts and theming
    if ! sudo pacman -S --needed --noconfirm \
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
        libadwaita 2>/dev/null; then
        print_warning "Some fonts/theming packages failed to install"
        failed_groups+=("Fonts and theming")
    fi
    
    print_success "Base dependencies installation completed"
}

# Function to install Hyprland
install_hyprland() {
    print_status "Installing Hyprland..."
    
    # Install Hyprland from official repos
    if ! sudo pacman -S --needed --noconfirm hyprland hyprpaper hyprpicker hyprlock hypridle 2>/dev/null; then
        print_warning "Some Hyprland packages failed to install"
        failed_groups+=("Hyprland core")
    fi
    
    # Install additional Hyprland utilities
    if ! sudo pacman -S --needed --noconfirm \
        grim \
        slurp \
        wl-clipboard 2>/dev/null; then
        print_warning "Some Hyprland utilities failed to install"
        failed_groups+=("Hyprland utilities")
    fi
    
    print_success "Hyprland installation completed"
}

# Function to install AUR helper (yay)
install_aur_helper() {
    print_status "Installing AUR helper (yay)..."
    
    if ! command -v yay &> /dev/null; then
        if ! cd /tmp 2>/dev/null; then
            print_warning "Failed to change to /tmp directory"
            failed_operations+=("AUR helper installation")
            return 1
        fi
        
        if ! git clone https://aur.archlinux.org/yay.git 2>/dev/null; then
            print_warning "Failed to clone yay repository"
            failed_packages+=("yay")
            return 1
        fi
        
        if ! cd yay 2>/dev/null; then
            print_warning "Failed to enter yay directory"
            failed_packages+=("yay")
            return 1
        fi
        
        if ! makepkg -si --noconfirm 2>/dev/null; then
            print_warning "Failed to build and install yay"
            failed_packages+=("yay")
            cd /tmp
            rm -rf yay 2>/dev/null
            return 1
        fi
        
        cd /tmp
        rm -rf yay 2>/dev/null
        print_success "yay installed"
    else
        print_status "yay is already installed"
    fi
}

# Function to install AUR packages
install_aur_packages() {
    print_status "Installing AUR packages..."
    
    # Check if yay is available
    if ! command -v yay &> /dev/null; then
        print_warning "yay not available, skipping AUR packages"
        failed_groups+=("AUR packages")
        return 1
    fi
    
    # Install essential AUR packages
    if ! yay -S --needed --noconfirm swww 2>/dev/null; then
        print_warning "swww failed to install"
        failed_packages+=("swww")
    fi
    
    if ! yay -S --needed --noconfirm grimblast-git 2>/dev/null; then
        print_warning "grimblast-git failed to install"
        failed_packages+=("grimblast-git")
    fi
    
    print_success "AUR packages installation completed"
}

# Function to install AGS (Advanced Gtk+ Sequencer)
install_ags() {
    print_status "Installing AGS (Advanced Gtk+ Sequencer)..."
    
    # Install dependencies
    if ! sudo pacman -S --needed --noconfirm \
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
        libadwaita 2>/dev/null; then
        print_warning "Some AGS dependencies failed to install"
        failed_groups+=("AGS dependencies")
    fi
    
    # Install AGS from AUR
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm ags-git 2>/dev/null; then
            print_warning "AGS failed to install"
            failed_packages+=("ags-git")
        fi
    else
        print_warning "yay not available, skipping AGS"
        failed_packages+=("ags-git")
    fi
    
    print_success "AGS installation completed"
}

# Function to install Fabric (alternative to AGS)
install_fabric() {
    print_status "Installing Fabric..."
    
    # Fabric is a modern widget toolkit (optional)
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm fabric-git 2>/dev/null; then
            print_warning "Fabric installation skipped (optional)"
            failed_packages+=("fabric-git (optional)")
        fi
    else
        print_warning "yay not available, skipping Fabric"
        failed_packages+=("fabric-git")
    fi
    
    print_success "Fabric installation attempted"
}

# Function to install application launchers
install_launchers() {
    print_status "Installing application launchers..."
    
    # Wofi (primary launcher)
    if ! sudo pacman -S --needed --noconfirm wofi 2>/dev/null; then
        print_warning "Wofi failed to install"
        failed_packages+=("wofi")
    fi
    
    # Additional launchers (optional)
    print_status "Installing optional wofi extensions..."
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm wofi-emoji 2>/dev/null; then
            print_warning "Optional wofi extensions skipped"
            failed_packages+=("wofi-emoji (optional)")
        fi
    fi
    
    print_success "Launchers installation completed"
}

# Function to install file managers
install_file_managers() {
    print_status "Installing file managers..."
    
    # Nautilus (GNOME file manager)
    if ! sudo pacman -S --needed --noconfirm \
        nautilus \
        file-roller \
        gvfs \
        gvfs-mtp \
        gvfs-afc \
        gvfs-gphoto2 \
        gvfs-nfs \
        gvfs-smb 2>/dev/null; then
        print_warning "Some Nautilus packages failed to install"
        failed_groups+=("Nautilus file manager")
    fi
    
    # Thunar (XFCE file manager) - alternative
    if ! sudo pacman -S --needed --noconfirm \
        thunar \
        thunar-archive-plugin \
        thunar-media-tags-plugin \
        tumbler 2>/dev/null; then
        print_warning "Some Thunar packages failed to install"
        failed_groups+=("Thunar file manager")
    fi
    
    print_success "File managers installation completed"
}

# Function to install terminal and development tools
install_terminal_tools() {
    print_status "Installing terminal and development tools..."
    
    # Terminal emulators
    if ! sudo pacman -S --needed --noconfirm \
        alacritty \
        kitty \
        foot 2>/dev/null; then
        print_warning "Some terminal emulators failed to install"
        failed_groups+=("Terminal emulators")
    fi
    
    # Shell and tools
    if ! sudo pacman -S --needed --noconfirm \
        zsh \
        fish \
        starship \
        eza \
        bat \
        fd \
        ripgrep \
        fzf \
        tmux \
        neovim 2>/dev/null; then
        print_warning "Some shell tools failed to install"
        failed_groups+=("Shell and CLI tools")
    fi
    
    # Development tools (optional)
    if ! sudo pacman -S --needed --noconfirm \
        rustup \
        go 2>/dev/null; then
        print_warning "Some dev tools skipped (optional)"
        failed_groups+=("Development tools (optional)")
    fi
    
    print_success "Terminal and development tools installation completed"
}

# Function to install macOS theme components
install_macos_theme() {
    print_status "Installing macOS theme components..."
    
    # Install macOS themes from AUR
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm \
            macos-sierra-gtk-theme-git \
            macos-sierra-icon-theme-git \
            macos-cursors-git \
            macos-wallpapers-git \
            san-francisco-pro-fonts-git \
            sf-mono-fonts-git \
            sf-pro-fonts-git 2>/dev/null; then
            print_warning "Some macOS theme components failed to install"
            failed_groups+=("macOS theme components")
        fi
    else
        print_warning "yay not available, skipping macOS themes"
        failed_groups+=("macOS theme components")
    fi
    
    # Install additional theming tools
    if ! sudo pacman -S --needed --noconfirm \
        lxappearance \
        qt5ct \
        qt6ct \
        kvantum 2>/dev/null; then
        print_warning "Some theming tools failed to install"
        failed_groups+=("Theming tools")
    fi
    
    print_success "macOS theme components installation completed"
}

# Function to install wallpaper engine dependencies
install_wallpaper_deps() {
    print_status "Installing wallpaper engine dependencies..."
    
    # Video wallpaper dependencies
    if ! sudo pacman -S --needed --noconfirm \
        mpv \
        ffmpeg \
        ffmpegthumbnailer \
        libmpv 2>/dev/null; then
        print_warning "Some video wallpaper dependencies failed to install"
        failed_groups+=("Video wallpaper dependencies")
    fi
    
    # Image wallpaper dependencies
    if ! sudo pacman -S --needed --noconfirm \
        imagemagick \
        feh 2>/dev/null; then
        print_warning "Some image wallpaper dependencies failed to install"
        failed_groups+=("Image wallpaper dependencies")
    fi
    
    # Install wallpaper engines from AUR
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm swww 2>/dev/null; then
            print_warning "swww installation skipped"
            failed_packages+=("swww")
        fi
    fi
    
    print_success "Wallpaper engine dependencies installation completed"
}

# Function to install utility applications
install_utility_apps() {
    print_status "Installing utility applications..."
    
    # System utilities
    if ! sudo pacman -S --needed --noconfirm \
        neofetch \
        htop \
        btop 2>/dev/null; then
        print_warning "Some system utilities failed to install"
        failed_groups+=("System utilities")
    fi
    
    # Network utilities
    if ! sudo pacman -S --needed --noconfirm \
        networkmanager \
        nm-connection-editor \
        blueman \
        bluez \
        bluez-utils \
        openssh 2>/dev/null; then
        print_warning "Some network utilities failed to install"
        failed_groups+=("Network utilities")
    fi
    
    # Media utilities (optional)
    if ! sudo pacman -S --needed --noconfirm \
        mpv \
        gimp 2>/dev/null; then
        print_warning "Some media apps skipped (optional)"
        failed_groups+=("Media apps (optional)")
    fi
    
    # Office and productivity (optional)
    if ! sudo pacman -S --needed --noconfirm firefox 2>/dev/null; then
        print_warning "Some productivity apps skipped (optional)"
        failed_packages+=("firefox (optional)")
    fi
    
    # Install additional utilities from AUR (optional)
    print_status "Installing optional AUR utilities..."
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm visual-studio-code-bin 2>/dev/null; then
            print_warning "VS Code skipped (optional)"
            failed_packages+=("visual-studio-code-bin (optional)")
        fi
        if ! yay -S --needed --noconfirm spotify 2>/dev/null; then
            print_warning "Spotify skipped (optional)"
            failed_packages+=("spotify (optional)")
        fi
    fi
    
    print_success "Utility applications installation completed"
}

# Function to create user directories
create_user_dirs() {
    print_status "Creating user directories..."
    
    # Create standard XDG directories
    if ! xdg-user-dirs-update 2>/dev/null; then
        print_warning "Failed to update XDG user directories"
        failed_operations+=("XDG user directories")
    fi
    
    # Create project-specific directories
    local dirs=(
        "$HOME/.config/hypr"
        "$HOME/.config/ags"
        "$HOME/.config/waybar"
        "$HOME/.config/wofi"
        "$HOME/.config/wallpaper"
        "$HOME/.config/gSlapper"
        "$HOME/.config/swww"
        "$HOME/.local/share/applications"
        "$HOME/.local/bin"
        "$HOME/Documents/Wallpapers"
        "$HOME/Pictures/Screenshots"
        "$HOME/Development"
    )
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            print_warning "Failed to create directory: $dir"
            failed_operations+=("Create directory: $(basename "$dir")")
        fi
    done
    
    print_success "User directories created"
}

# Function to install fonts
install_fonts() {
    print_status "Installing additional fonts..."
    
    # Install nerd fonts for icons (selected fonts only)
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm ttf-meslo-nerd 2>/dev/null; then
            print_warning "Nerd fonts skipped"
            failed_packages+=("ttf-meslo-nerd")
        fi
    else
        print_warning "yay not available, skipping nerd fonts"
        failed_packages+=("ttf-meslo-nerd")
    fi
    
    if command -v yay &> /dev/null; then
        if ! yay -S --needed --noconfirm ttf-jetbrains-mono-nerd 2>/dev/null; then
            print_warning "JetBrains Mono Nerd skipped"
            failed_packages+=("ttf-jetbrains-mono-nerd")
        fi
    fi
    
    # Install emoji fonts
    if ! sudo pacman -S --needed --noconfirm noto-fonts-emoji 2>/dev/null; then
        print_warning "Emoji fonts failed to install"
        failed_packages+=("noto-fonts-emoji")
    fi
    
    # Update font cache
    if ! fc-cache -fv 2>/dev/null; then
        print_warning "Failed to update font cache"
        failed_operations+=("Font cache update")
    fi
    
    print_success "Fonts installation completed"
}

# Function to enable system services
enable_services() {
    print_status "Enabling system services..."
    
    # NetworkManager
    if ! sudo systemctl enable NetworkManager.service 2>/dev/null; then
        print_warning "Failed to enable NetworkManager"
        failed_operations+=("Enable NetworkManager")
    fi
    if ! sudo systemctl start NetworkManager.service 2>/dev/null; then
        print_warning "Failed to start NetworkManager"
        failed_operations+=("Start NetworkManager")
    fi
    
    # Bluetooth
    if ! sudo systemctl enable bluetooth.service 2>/dev/null; then
        print_warning "Failed to enable Bluetooth (might not be installed)"
        failed_operations+=("Enable Bluetooth")
    fi
    if ! sudo systemctl start bluetooth.service 2>/dev/null; then
        print_warning "Failed to start Bluetooth"
        failed_operations+=("Start Bluetooth")
    fi
    
    # PipeWire
    if ! systemctl --user enable pipewire.service 2>/dev/null; then
        print_warning "Failed to enable PipeWire"
        failed_operations+=("Enable PipeWire")
    fi
    if ! systemctl --user start pipewire.service 2>/dev/null; then
        print_warning "Failed to start PipeWire"
        failed_operations+=("Start PipeWire")
    fi
    
    if ! systemctl --user enable pipewire-pulse.service 2>/dev/null; then
        print_warning "Failed to enable PipeWire Pulse"
        failed_operations+=("Enable PipeWire Pulse")
    fi
    if ! systemctl --user start pipewire-pulse.service 2>/dev/null; then
        print_warning "Failed to start PipeWire Pulse"
        failed_operations+=("Start PipeWire Pulse")
    fi
    
    if ! systemctl --user enable wireplumber.service 2>/dev/null; then
        print_warning "Failed to enable WirePlumber"
        failed_operations+=("Enable WirePlumber")
    fi
    if ! systemctl --user start wireplumber.service 2>/dev/null; then
        print_warning "Failed to start WirePlumber"
        failed_operations+=("Start WirePlumber")
    fi
    
    # SSH
    if ! sudo systemctl enable sshd.service 2>/dev/null; then
        print_warning "Failed to enable SSH (might not be installed)"
        failed_operations+=("Enable SSH")
    fi
    
    print_success "System services configuration completed"
}

# Function to clone and setup repositories
setup_repositories() {
    print_status "Setting up additional repositories..."
    
    if ! cd "$HOME/Development" 2>/dev/null; then
        print_warning "Failed to change to Development directory"
        failed_operations+=("Change to Development directory")
        return 1
    fi
    
    # Clone macOS theme repositories
    if [ ! -d "macos-sierra-gtk-theme" ]; then
        if ! git clone https://github.com/vinceliuice/macos-sierra-gtk-theme.git 2>/dev/null; then
            print_warning "Failed to clone macOS Sierra GTK theme"
            failed_operations+=("Clone macOS Sierra GTK theme")
        fi
    fi
    
    if [ ! -d "macOS-San-Francisco-Font" ]; then
        if ! git clone https://github.com/AppleDesignResources/SanFranciscoFont.git macOS-San-Francisco-Font 2>/dev/null; then
            print_warning "Failed to clone San Francisco Font"
            failed_operations+=("Clone San Francisco Font")
        fi
    fi
    
    # Clone Hyprland configurations
    if [ ! -d "hyprland-macos-config" ]; then
        if ! git clone https://github.com/prasanthrangan/hyprdots.git hyprland-macos-config 2>/dev/null; then
            print_warning "Failed to clone Hyprland configs"
            failed_operations+=("Clone Hyprland configs")
        fi
    fi
    
    # Clone AGS widget examples
    if [ ! -d "ags-widgets" ]; then
        if ! git clone https://github.com/Aylur/ags-widgets.git 2>/dev/null; then
            print_warning "Failed to clone AGS widgets"
            failed_operations+=("Clone AGS widgets")
        fi
    fi
    
    print_success "Repositories setup completed"
}

# Function to set permissions
set_permissions() {
    print_status "Setting file permissions..."
    
    # Make scripts executable
    if ! chmod +x "$PROJECT_ROOT/scripts/"*.sh 2>/dev/null; then
        print_warning "Failed to make some project scripts executable"
        failed_operations+=("Make project scripts executable")
    fi
    
    if ! chmod +x "$HOME/.local/bin/"* 2>/dev/null; then
        print_warning "Failed to make some user scripts executable"
        failed_operations+=("Make user scripts executable")
    fi
    
    # Set user ownership
    if ! sudo chown -R "$USER:$USER" "$CONFIG_DIR" 2>/dev/null; then
        print_warning "Failed to set ownership for config directory"
        failed_operations+=("Set config directory ownership")
    fi
    
    if ! sudo chown -R "$USER:$USER" "$HOME/.local" 2>/dev/null; then
        print_warning "Failed to set ownership for .local directory"
        failed_operations+=("Set .local directory ownership")
    fi
    
    print_success "Permissions configuration completed"
}

# Function to print completion message
print_completion() {
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    # Display summary
    if [ ${#failed_packages[@]} -eq 0 ] && [ ${#failed_groups[@]} -eq 0 ] && [ ${#failed_operations[@]} -eq 0 ]; then
        print_success "✓✓✓ Installation completed successfully! ✓✓✓"
    else
        print_warning "Installation completed with some issues:"
        echo
        
        if [ ${#failed_groups[@]} -gt 0 ]; then
            echo -e "${YELLOW}Component groups with issues:${NC}"
            for group in "${failed_groups[@]}"; do
                echo -e "  ${RED}✗${NC} $group"
            done
            echo
        fi
        
        if [ ${#failed_packages[@]} -gt 0 ]; then
            echo -e "${YELLOW}Individual packages that failed:${NC}"
            for pkg in "${failed_packages[@]}"; do
                echo -e "  ${RED}✗${NC} $pkg"
            done
            echo
        fi
        
        if [ ${#failed_operations[@]} -gt 0 ]; then
            echo -e "${YELLOW}Operations that failed:${NC}"
            for op in "${failed_operations[@]}"; do
                echo -e "  ${RED}✗${NC} $op"
            done
            echo
        fi
        
        echo -e "${YELLOW}Note: You can try installing failed packages manually.${NC}"
        echo -e "${YELLOW}Most packages are optional and the system should work.${NC}"
        echo
    fi
    
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