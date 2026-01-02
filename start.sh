#!/bin/bash

# macOS Tahoe - Quick Start Script
# One-command setup for the complete macOS Tahoe experience

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Mode flag
AUTO_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto|--automated|-a)
            AUTO_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --auto, -a         Run automated installation (no prompts)"
            echo "  --help, -h         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

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

# Function to print banner
print_banner() {
    echo -e "${BLUE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo "           macOS Tahoe on Arch Linux - Hyprland Edition"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if running on Arch Linux
    if [ ! -f /etc/arch-release ]; then
        print_error "This script is designed for Arch Linux only!"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_error "Run as regular user with sudo privileges."
        exit 1
    fi
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed! Please install git first."
        exit 1
    fi
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed! Please install curl first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to detect desktop environment
detect_desktop() {
    if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
        echo "hyprland"
    elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        echo "wayland"
    elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
        echo "x11"
    else
        echo "unknown"
    fi
}

# Function to show menu
show_menu() {
    print_banner
    echo
    echo -e "${YELLOW}Choose an option:${NC}"
    echo
    echo -e "  ${GREEN}1)${NC} Install macOS Tahoe (Complete Setup)"
    echo -e "  ${GREEN}2)${NC} Apply Configurations Only"
    echo -e "  ${GREEN}3)${NC} Apply Theme Only"
    echo -e "  ${GREEN}4)${NC} Launch Wallpaper Picker"
    echo -e "  ${GREEN}5)${NC} System Information"
    echo -e "  ${GREEN}6)${NC} Troubleshooting"
    echo -e "  ${GREEN}7)${NC} Uninstall macOS Tahoe"
    echo -e "  ${GREEN}8)${NC} Exit"
    echo
    echo -n -e "${YELLOW}Enter your choice (1-8): ${NC}"
}

# Function to install all required packages
install_all_packages() {
    print_status "Installing all required packages for macOS Tahoe..."
    echo
    
    # Arrays to track failed installations
    local failed_packages=()
    local failed_groups=()
    
    # Update system first
    print_status "Updating system packages..."
    if ! sudo pacman -Syu --noconfirm 2>/dev/null; then
        print_warning "System update had some issues, continuing..."
    fi
    print_success "✓ System update attempted"
    echo
    
    # Install base dependencies
    print_status "Installing base dependencies..."
    if ! sudo pacman -S --needed --noconfirm \
        base-devel git curl wget unzip zip cmake meson ninja gcc pkg-config 2>/dev/null; then
        print_warning "Some base dependencies failed"
        failed_groups+=("base-devel tools")
    fi
    print_success "✓ Base dependencies attempted"
    
    # Install Wayland and Hyprland dependencies
    print_status "Installing Wayland and Hyprland dependencies..."
    if ! sudo pacman -S --needed --noconfirm \
        wayland wayland-protocols libdrm \
        libxkbcommon pixman cairo pango gdk-pixbuf2 librsvg glib2 2>/dev/null; then
        print_warning "Some Wayland dependencies failed"
        failed_groups+=("Wayland dependencies")
    fi
    print_success "✓ Wayland dependencies attempted"
    
    # Install Hyprland and utilities
    print_status "Installing Hyprland and utilities..."
    if ! sudo pacman -S --needed --noconfirm \
        hyprland hyprpaper hyprpicker hyprlock hypridle \
        slurp wl-clipboard grim 2>/dev/null; then
        print_warning "Some Hyprland packages failed"
        failed_groups+=("Hyprland")
    fi
    print_success "✓ Hyprland installation attempted"
    
    # Install graphics and rendering (optional GPU drivers)
    print_status "Installing graphics libraries..."
    if ! sudo pacman -S --needed --noconfirm \
        mesa libglvnd 2>/dev/null; then
        print_warning "Graphics packages failed"
        failed_groups+=("Graphics libraries")
    fi
    
    # Try to install GPU drivers (non-critical)
    print_status "Installing GPU drivers (optional)..."
    sudo pacman -S --needed --noconfirm \
        vulkan-radeon vulkan-intel 2>/dev/null || print_warning "Some GPU drivers skipped"
    
    # NVIDIA drivers only if NVIDIA GPU detected
    if lspci 2>/dev/null | grep -i nvidia &> /dev/null; then
        print_status "NVIDIA GPU detected, installing drivers..."
        sudo pacman -S --needed --noconfirm nvidia-utils 2>/dev/null || print_warning "NVIDIA drivers skipped"
    fi
    
    print_success "✓ Graphics packages attempted"
    
    # Install audio and multimedia
    print_status "Installing audio and multimedia packages..."
    if ! sudo pacman -S --needed --noconfirm \
        pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol alsa-utils \
        ffmpeg ffmpegthumbnailer gst-plugins-base gst-plugins-good \
        gst-plugins-bad gst-plugins-ugly mpv 2>/dev/null; then
        print_warning "Some audio packages failed"
        failed_groups+=("Audio/Multimedia")
    fi
    print_success "✓ Audio and multimedia attempted"
    
    
    # Install fonts
    print_status "Installing fonts..."
    if ! sudo pacman -S --needed --noconfirm \
        ttf-dejavu ttf-liberation ttf-roboto ttf-opensans \
        ttf-font-awesome noto-fonts noto-fonts-emoji ttf-fira-code \
        ttf-jetbrains-mono ttf-cascadia-code ttf-hack \
        adobe-source-code-pro-fonts 2>/dev/null; then
        print_warning "Some fonts failed"
        failed_groups+=("Fonts")
    fi
    print_success "✓ Fonts attempted"
    
    # Install icon themes
    print_status "Installing icon themes..."
    if ! sudo pacman -S --needed --noconfirm \
        adwaita-icon-theme hicolor-icon-theme papirus-icon-theme 2>/dev/null; then
        print_warning "Some icon themes failed"
        failed_groups+=("Icon themes")
    fi
    print_success "✓ Icon themes attempted"
    
    # Install GTK and theming
    print_status "Installing GTK and theming packages..."
    if ! sudo pacman -S --needed --noconfirm \
        gtk3 gtk4 libadwaita \
        sassc optipng inkscape imagemagick librsvg \
        lxappearance papirus-icon-theme \
        qt5ct qt6ct kvantum 2>/dev/null; then
        print_warning "Some GTK packages failed"
        failed_groups+=("GTK/Theming")
    fi
    print_success "✓ GTK and theming attempted"
    
    # Install launchers and utilities
    print_status "Installing application launchers and system utilities..."
    if ! sudo pacman -S --needed --noconfirm \
        wofi brightnessctl playerctl network-manager-applet \
        blueman dunst 2>/dev/null; then
        print_warning "Some launchers failed"
        failed_groups+=("Launchers")
    fi
    
    # Polkit agent
    sudo pacman -S --needed --noconfirm polkit-kde-agent 2>/dev/null || \
        sudo pacman -S --needed --noconfirm polkit-gnome 2>/dev/null || \
        print_warning "No polkit agent installed"
    
    print_success "✓ Launchers and utilities attempted"
    
    # Install desktop portals
    print_status "Installing desktop portals..."
    if ! sudo pacman -S --needed --noconfirm \
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk 2>/dev/null; then
        print_warning "Some desktop portals failed"
        failed_groups+=("Desktop portals")
    fi
    print_success "✓ Desktop portals attempted"
    
    # Install file managers
    print_status "Installing file managers..."
    if ! sudo pacman -S --needed --noconfirm \
        nautilus file-roller \
        gvfs gvfs-mtp gvfs-afc gvfs-gphoto2 gvfs-nfs gvfs-smb \
        thunar thunar-archive-plugin thunar-media-tags-plugin \
        tumbler 2>/dev/null; then
        print_warning "Some file manager packages failed"
        failed_groups+=("File managers")
    fi
    print_success "✓ File managers attempted"
    
    # Install terminal emulators
    print_status "Installing terminal emulators..."
    if ! sudo pacman -S --needed --noconfirm \
        alacritty kitty foot 2>/dev/null; then
        print_warning "Some terminal emulators failed"
        failed_groups+=("Terminal emulators")
    fi
    print_success "✓ Terminal emulators attempted"
    
    # Install shell tools
    print_status "Installing shell and development tools..."
    sudo pacman -S --needed --noconfirm \
        zsh fish starship eza bat fd ripgrep fzf tmux neovim 2>/dev/null || \
        print_warning "Some shell tools failed"
    print_success "✓ Shell tools attempted"
    
    # Install system utilities
    print_status "Installing system utilities..."
    sudo pacman -S --needed --noconfirm \
        neofetch htop btop networkmanager nm-connection-editor \
        bluez bluez-utils openssh feh 2>/dev/null || \
        print_warning "Some utilities failed"
    print_success "✓ System utilities attempted"
    
    # Install applications (optional)
    print_status "Installing productivity applications (optional)..."
    sudo pacman -S --needed --noconfirm \
        firefox gimp 2>/dev/null || \
        print_warning "Some applications skipped"
    print_success "✓ Applications attempted"
    
    # Install AGS dependencies
    print_status "Installing AGS dependencies..."
    if ! sudo pacman -S --needed --noconfirm \
        gobject-introspection vala libgee json-glib libxml2 libsoup3 gstreamer 2>/dev/null; then
        print_warning "Some AGS dependencies failed"
        failed_groups+=("AGS dependencies")
    fi
    print_success "✓ AGS dependencies attempted"
    
    # Install Python dependencies for wallpaper picker
    print_status "Installing Python dependencies..."
    sudo pacman -S --needed --noconfirm \
        python python-pip python-gobject python-cairo gtk3 2>/dev/null || \
        print_warning "Some Python dependencies failed"
    print_success "✓ Python dependencies attempted"
    
    # Install AUR helper (yay) if not present
    if ! command -v yay &> /dev/null; then
        print_status "Installing AUR helper (yay)..."
        (
            cd /tmp
            if [ -d "yay" ]; then
                rm -rf yay
            fi
            if git clone https://aur.archlinux.org/yay.git 2>/dev/null && cd yay && makepkg -si --noconfirm 2>/dev/null; then
                print_success "✓ yay installed"
            else
                print_warning "yay installation failed"
                failed_packages+=("yay")
            fi
            cd /tmp
            rm -rf yay
        ) || {
            print_warning "yay installation failed"
            failed_packages+=("yay")
        }
    else
        print_status "AUR helper (yay) already installed"
    fi
    
    # Install AUR packages only if yay is available
    if command -v yay &> /dev/null; then
        print_status "Installing AUR packages (this may take a while)..."
        echo
        
        # Install swww (wallpaper engine)
        print_status "Installing swww..."
        if ! yay -S --needed --noconfirm swww 2>/dev/null; then
            print_warning "swww installation failed"
            failed_packages+=("swww")
        fi
        
        # Install grimblast (screenshot utility)
        print_status "Installing grimblast..."
        if ! yay -S --needed --noconfirm grimblast-git 2>/dev/null; then
            print_warning "grimblast installation failed"
            failed_packages+=("grimblast-git")
        fi
        
        # Install AGS
        print_status "Installing AGS..."
        if ! yay -S --needed --noconfirm ags 2>/dev/null; then
            print_warning "AGS installation failed"
            failed_packages+=("ags")
        fi
        
        # Install wezterm terminal (optional)
        print_status "Installing wezterm (optional)..."
        yay -S --needed --noconfirm wezterm 2>/dev/null || print_warning "wezterm skipped"
        
        # Install additional fonts from AUR
        print_status "Installing additional fonts from AUR..."
        yay -S --needed --noconfirm ttf-ms-fonts 2>/dev/null || print_warning "MS fonts skipped"
        
        print_success "✓ AUR packages installation attempted"
    else
        print_warning "Skipping AUR packages (yay not available)"
        failed_groups+=("AUR packages")
    fi
    
    
    # Enable and start services
    print_status "Enabling system services..."
    sudo systemctl enable NetworkManager.service 2>/dev/null || true
    sudo systemctl start NetworkManager.service 2>/dev/null || true
    sudo systemctl enable bluetooth.service 2>/dev/null || true
    sudo systemctl start bluetooth.service 2>/dev/null || true
    systemctl --user enable pipewire.service 2>/dev/null || true
    systemctl --user start pipewire.service 2>/dev/null || true
    systemctl --user enable pipewire-pulse.service 2>/dev/null || true
    systemctl --user start pipewire-pulse.service 2>/dev/null || true
    systemctl --user enable wireplumber.service 2>/dev/null || true
    systemctl --user start wireplumber.service 2>/dev/null || true
    print_success "✓ Services enabled"
    
    # Update font cache
    print_status "Updating font cache..."
    fc-cache -fv > /dev/null 2>&1 || print_warning "Font cache update failed"
    print_success "✓ Font cache updated"
    
    echo
    echo "═══════════════════════════════════════════════════════════════"
    
    # Display summary
    if [ ${#failed_packages[@]} -eq 0 ] && [ ${#failed_groups[@]} -eq 0 ]; then
        print_success "✓✓✓ All packages installed successfully! ✓✓✓"
    else
        print_warning "Installation completed with some issues:"
        echo
        
        if [ ${#failed_groups[@]} -gt 0 ]; then
            echo -e "${YELLOW}Package groups with issues:${NC}"
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
        
        echo -e "${YELLOW}Note: You can try installing failed packages manually later.${NC}"
        echo -e "${YELLOW}Most packages are optional and the system should still work.${NC}"
    fi
    
    echo "═══════════════════════════════════════════════════════════════"
}

# Function for complete installation
complete_installation() {
    print_status "Starting complete macOS Tahoe installation..."
    echo
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local install_failed=false
    
    # Step 1: Install ALL required packages
    print_banner_step "Step 1/3: Installing ALL Required Packages"
    print_status "Installing packages from official repos and AUR..."
    print_status "This may take 15-30 minutes depending on your internet connection..."
    echo
    
    if ! install_all_packages; then
        print_error "Package installation failed!"
        install_failed=true
    fi
    
    if [ "$install_failed" = true ]; then
        print_error "Installation cannot continue due to package installation failure"
        return 1
    fi
    
    echo
    sleep 2
    
    # Step 2: Apply configurations
    print_banner_step "Step 2/3: Applying Configurations"
    print_status "Copying configuration files and setting up the environment..."
    echo
    
    if [ -f "$script_dir/scripts/setup.sh" ]; then
        if ! bash "$script_dir/scripts/setup.sh"; then
            print_error "Configuration setup failed!"
            return 1
        else
            print_success "✓ Configurations applied successfully"
        fi
    else
        print_error "setup.sh not found at $script_dir/scripts/setup.sh"
        return 1
    fi
    
    echo
    sleep 2
    
    # Step 3: Apply theme
    print_banner_step "Step 3/3: Applying macOS Tahoe Theme"
    print_status "Installing GTK themes, icons, and fonts..."
    echo
    
    if [ -f "$script_dir/scripts/theme.sh" ]; then
        if ! bash "$script_dir/scripts/theme.sh"; then
            print_error "Theme installation failed!"
            return 1
        else
            print_success "✓ Theme applied successfully"
        fi
    else
        print_error "theme.sh not found at $script_dir/scripts/theme.sh"
        return 1
    fi
    
    echo
    echo "═══════════════════════════════════════════════════════════════"
    print_success "Installation completed successfully!"
    echo "═══════════════════════════════════════════════════════════════"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "  1. ${GREEN}Reboot your system${NC} to complete the installation"
    echo -e "  2. ${GREEN}Select 'Hyprland'${NC} from your display manager login screen"
    echo -e "  3. ${GREEN}Enjoy your macOS Tahoe experience!${NC}"
    echo
    
    if [ "$AUTO_MODE" = true ]; then
        echo -e "${YELLOW}Auto-mode: Installation complete. System reboot recommended.${NC}"
    fi
}

# Function to print step banner
print_banner_step() {
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
}

# Function to apply configurations only
apply_configurations() {
    print_status "Applying configurations only..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -f "$script_dir/scripts/setup.sh" ]; then
        "$script_dir/scripts/setup.sh"
    else
        print_error "setup.sh not found!"
        return 1
    fi
}

# Function to apply theme only
apply_theme() {
    print_status "Applying macOS theme only..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -f "$script_dir/scripts/theme.sh" ]; then
        "$script_dir/scripts/theme.sh"
    else
        print_error "theme.sh not found!"
        return 1
    fi
}

# Function to launch wallpaper picker
launch_wallpaper_picker() {
    print_status "Launching wallpaper picker..."
    
    if command -v wallpaper-picker &> /dev/null; then
        wallpaper-picker &
        print_success "Wallpaper picker launched"
    else
        print_error "wallpaper-picker not found!"
        print_status "Please run 'scripts/setup.sh' first"
    fi
}

# Function to show system information
show_system_info() {
    print_status "Gathering system information..."
    echo
    echo -e "${BLUE}System Information:${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    
    # OS Info
    echo -e "${YELLOW}Operating System:${NC}"
    cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2
    
    # Kernel
    echo -e "\n${YELLOW}Kernel:${NC}"
    uname -r
    
    # Desktop Environment
    echo -e "\n${YELLOW}Desktop Environment:${NC}"
    detect_desktop
    
    # CPU Info
    echo -e "\n${YELLOW}CPU:${NC}"
    lscpu | grep "Model name" | cut -d':' -f2 | xargs
    
    # RAM Info
    echo -e "\n${YELLOW}Memory:${NC}"
    free -h | grep "Mem:" | awk '{print $2 " total, " $3 " used"}'
    
    # GPU Info
    echo -e "\n${YELLOW}GPU:${NC}"
    lspci | grep VGA | cut -d':' -f3 | xargs
    
    # Hyprland Status
    echo -e "\n${YELLOW}Hyprland Status:${NC}"
    if command -v hyprctl &> /dev/null; then
        echo "Installed: Yes"
        hyprctl version | grep "Hyprland"
    else
        echo "Installed: No"
    fi
    
    # Theme Status
    echo -e "\n${YELLOW}Theme Status:${NC}"
    if [ -d "$HOME/.themes/macos-sierra-gtk-theme" ]; then
        echo "macOS Theme: Installed"
    else
        echo "macOS Theme: Not installed"
    fi
    
    # Font Status
    echo -e "\n${YELLOW}Font Status:${NC}"
    if fc-list | grep -q "SF Pro"; then
        echo "SF Pro Fonts: Installed"
    else
        echo "SF Pro Fonts: Not installed"
    fi
    
    echo "═══════════════════════════════════════════════════════════════"
}

# Function for troubleshooting
show_troubleshooting() {
    print_status "Troubleshooting information..."
    echo
    echo -e "${YELLOW}Common Issues and Solutions:${NC}"
    echo
    echo -e "${BLUE}1. Black Screen on Boot:${NC}"
    echo "   - Check GPU drivers: lspci | grep VGA"
    echo "   - Install appropriate drivers for your GPU"
    echo
    echo -e "${BLUE}2. No Audio:${NC}"
    echo "   - Check PipeWire: pactl info"
    echo "   - Restart audio: systemctl --user restart pipewire"
    echo
    echo -e "${BLUE}3. Theme Not Applied:${NC}"
    echo "   - Check theme installation: ls ~/.themes"
    echo "   - Apply manually: ./scripts/theme.sh"
    echo
    echo -e "${BLUE}4. Fonts Not Working:${NC}"
    echo "   - Check font installation: fc-list | grep 'SF Pro'"
    echo "   - Update font cache: fc-cache -fv"
    echo
    echo -e "${BLUE}5. Hyprland Not Starting:${NC}"
    echo "   - Check logs: ~/.cache/hyprland/hyprland.log"
    echo "   - Verify configuration: hyprctl reload"
    echo
    echo -e "${YELLOW}For more help, see docs/TROUBLESHOOTING.md${NC}"
}

# Function for uninstallation
uninstall() {
    print_status "Starting macOS Tahoe uninstallation..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -f "$script_dir/scripts/uninstall.sh" ]; then
        "$script_dir/scripts/uninstall.sh"
    else
        print_error "uninstall.sh not found!"
        return 1
    fi
}

# Function for automated installation
automated_installation() {
    clear
    print_banner
    echo
    print_status "Running in AUTOMATED mode - No user prompts"
    print_status "All scripts will run sequentially..."
    echo
    
    # Run complete installation
    if complete_installation; then
        echo
        print_success "Automated installation completed successfully!"
        echo
        echo -e "${YELLOW}Your system is now configured with macOS Tahoe.${NC}"
        echo -e "${YELLOW}Please reboot to apply all changes.${NC}"
        exit 0
    else
        echo
        print_error "Automated installation failed!"
        echo -e "${YELLOW}Please check the error messages above and try again.${NC}"
        echo -e "${YELLOW}You can also run in interactive mode: ./start.sh${NC}"
        exit 1
    fi
}

# Main function
main() {
    check_prerequisites
    
    # If auto mode is enabled, run automated installation
    if [ "$AUTO_MODE" = true ]; then
        automated_installation
        exit 0
    fi
    
    # Otherwise, show interactive menu
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                clear
                complete_installation
                echo
                read -p "Press Enter to continue..."
                ;;
            2)
                clear
                apply_configurations
                echo
                read -p "Press Enter to continue..."
                ;;
            3)
                clear
                apply_theme
                echo
                read -p "Press Enter to continue..."
                ;;
            4)
                launch_wallpaper_picker
                echo
                read -p "Press Enter to continue..."
                ;;
            5)
                clear
                show_system_info
                echo
                read -p "Press Enter to continue..."
                ;;
            6)
                clear
                show_troubleshooting
                echo
                read -p "Press Enter to continue..."
                ;;
            7)
                clear
                uninstall
                echo
                read -p "Press Enter to continue..."
                ;;
            8)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice! Please enter 1-8"
                echo
                read -p "Press Enter to continue..."
                ;;
        esac
        
        clear
    done
}

# Run main function
main "$@"