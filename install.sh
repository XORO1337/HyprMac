#!/bin/bash

# HyprMac Installation Script
# macOS-style Hyprland desktop with AGS (Aylur's GTK Shell)

# DON'T use set -e - we handle errors manually to continue on failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track errors
ERRORS=()

# Error handler function
log_error() {
    ERRORS+=("$1")
    echo -e "  ${RED}✗ ERROR:${NC} $1"
}

# Success handler function
log_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

# Warning handler function
log_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

# Install pacman packages with error handling
install_pacman_packages() {
    local packages=("$@")
    local failed=()
    
    for pkg in "${packages[@]}"; do
        # Check if package exists in repos
        if pacman -Si "$pkg" &>/dev/null; then
            if sudo pacman -S --needed --noconfirm "$pkg" &>/dev/null; then
                log_success "Installed $pkg"
            else
                log_error "Failed to install $pkg"
                failed+=("$pkg")
            fi
        else
            log_warning "Package $pkg not found in repos, skipping"
            failed+=("$pkg")
        fi
    done
    
    return ${#failed[@]}
}

# Install AUR packages with error handling
install_aur_packages() {
    local packages=("$@")
    local failed=()
    
    for pkg in "${packages[@]}"; do
        if yay -S --needed --noconfirm "$pkg" &>/dev/null; then
            log_success "Installed $pkg (AUR)"
        else
            log_warning "Failed to install $pkg from AUR, skipping"
            failed+=("$pkg")
        fi
    done
    
    return ${#failed[@]}
}

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                       HyprMac                             ║"
echo "║          macOS-style Desktop for Hyprland                 ║"
echo "║                  Powered by AGS                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}Starting installation...${NC}\n"

# ============================================
# Step 1: Update system
# ============================================
echo -e "${GREEN}[1/8] Updating system packages...${NC}"
if sudo pacman -Syu --noconfirm; then
    log_success "System updated"
else
    log_warning "System update had issues, continuing anyway"
fi

# ============================================
# Step 2: Install yay if not present
# ============================================
echo -e "\n${GREEN}[2/8] Checking AUR helper (yay)...${NC}"
if command -v yay &> /dev/null; then
    log_success "yay is already installed"
else
    echo -e "  ${YELLOW}yay not found. Installing yay...${NC}"
    if sudo pacman -S --needed git base-devel --noconfirm; then
        TEMP_DIR=$(mktemp -d)
        if git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay" 2>/dev/null; then
            cd "$TEMP_DIR/yay" || exit
            if makepkg -si --noconfirm; then
                log_success "yay installed successfully"
            else
                log_error "Failed to build yay"
            fi
            cd - > /dev/null || exit
        else
            log_error "Failed to clone yay repository"
        fi
        rm -rf "$TEMP_DIR"
    else
        log_error "Failed to install yay dependencies"
    fi
fi

# ============================================
# Step 3: Install core system packages
# ============================================
echo -e "\n${GREEN}[3/8] Installing Hyprland and core dependencies...${NC}"

# Core packages (essential)
CORE_PACKAGES=(
    hyprland
    gtk3
    gtk-layer-shell
    gjs
    swww
    brightnessctl
    playerctl
    polkit
    seatd
    xorg-xwayland
    kitty
    nautilus
    libnotify
    sassc
    ffmpeg
    imagemagick
)

# Optional packages (nice to have)
OPTIONAL_PACKAGES=(
    swaync
    upower
    networkmanager
    libpulse
    ttf-font-awesome
    otf-font-awesome
    gnome-tweaks
    bluez
    bluez-utils
    gammastep
    sassc
    gnome-bluetooth-3.0
    power-profiles-daemon
    cpupower
    mpv
)

echo -e "  Installing core packages..."
for pkg in "${CORE_PACKAGES[@]}"; do
    if pacman -Si "$pkg" &>/dev/null; then
        if sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
            log_success "$pkg"
        else
            log_error "Failed to install $pkg"
        fi
    else
        log_warning "$pkg not found, skipping"
    fi
done

echo -e "\n  Installing optional packages..."
for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if pacman -Si "$pkg" &>/dev/null; then
        sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null && log_success "$pkg" || log_warning "$pkg failed, skipping"
    else
        # Try alternative package names
        case "$pkg" in
            "gnome-bluetooth-3.0")
                # Try alternative names
                for alt in "gnome-bluetooth" "blueman"; do
                    if pacman -Si "$alt" &>/dev/null; then
                        sudo pacman -S --needed --noconfirm "$alt" 2>/dev/null && log_success "$alt (alternative)" && break
                    fi
                done
                ;;
            *)
                log_warning "$pkg not found, skipping"
                ;;
        esac
    fi
done

# ============================================
# Step 4: Install AGS
# ============================================
echo -e "\n${GREEN}[4/8] Installing AGS (Aylur's GTK Shell)...${NC}"
if command -v yay &> /dev/null; then
    # Try different AGS package names
    AGS_INSTALLED=false
    for ags_pkg in "aylurs-gtk-shell" "ags" "ags-git"; do
        if yay -S --needed --noconfirm "$ags_pkg" 2>/dev/null; then
            log_success "Installed $ags_pkg"
            AGS_INSTALLED=true
            break
        fi
    done
    if [ "$AGS_INSTALLED" = false ]; then
        log_error "Could not install AGS - try manually: yay -S aylurs-gtk-shell"
    fi
else
    log_error "yay not available, cannot install AGS"
fi

# ============================================
# Step 5: Install AUR packages and fonts
# ============================================
echo -e "\n${GREEN}[5/8] Installing AUR packages and fonts...${NC}"
if command -v yay &> /dev/null; then
    AUR_PACKAGES=(
        "otf-apple-sf-pro"
        "otf-apple-sf-mono"  
        "ttf-nerd-fonts-symbols"
        "hyprlock"
        "hypridle"
        "gslapper"
    )
    
    for pkg in "${AUR_PACKAGES[@]}"; do
        if yay -S --needed --noconfirm "$pkg" 2>/dev/null; then
            log_success "$pkg"
        else
            log_warning "$pkg failed, skipping"
        fi
    done
    
    # Try alternative font packages if Apple fonts fail
    if ! fc-list | grep -qi "SF Pro" 2>/dev/null; then
        log_warning "SF Pro font not installed, trying alternatives..."
        for alt_font in "ttf-dejavu" "ttf-liberation" "noto-fonts"; do
            sudo pacman -S --needed --noconfirm "$alt_font" 2>/dev/null && log_success "$alt_font (fallback font)"
        done
    fi
else
    log_error "yay not available, skipping AUR packages"
fi

# ============================================
# Step 6: Enable services
# ============================================
echo -e "\n${GREEN}[6/8] Enabling necessary services...${NC}"

# Enable seatd
if systemctl list-unit-files | grep -q "seatd.service"; then
    sudo systemctl enable seatd.service 2>/dev/null && log_success "seatd enabled" || log_warning "seatd enable failed"
    sudo systemctl start seatd.service 2>/dev/null || true
else
    log_warning "seatd.service not found"
fi

# Enable bluetooth
if systemctl list-unit-files | grep -q "bluetooth.service"; then
    sudo systemctl enable bluetooth.service 2>/dev/null && log_success "bluetooth enabled" || log_warning "bluetooth enable failed"
    sudo systemctl start bluetooth.service 2>/dev/null || true
else
    log_warning "bluetooth.service not found"
fi

# Enable NetworkManager
if systemctl list-unit-files | grep -q "NetworkManager.service"; then
    sudo systemctl enable NetworkManager.service 2>/dev/null && log_success "NetworkManager enabled" || log_warning "NetworkManager enable failed"
    sudo systemctl start NetworkManager.service 2>/dev/null || true
else
    log_warning "NetworkManager.service not found"
fi

# ============================================
# Step 7: Install hyprexpo plugin
# ============================================
echo -e "\n${GREEN}[7/8] Installing hyprexpo plugin (Mission Control)...${NC}"
if command -v hyprpm &> /dev/null; then
    hyprpm update 2>/dev/null || log_warning "hyprpm update failed"
    if hyprpm add https://github.com/hyprwm/hyprland-plugins 2>/dev/null; then
        log_success "hyprland-plugins added"
        hyprpm enable hyprexpo 2>/dev/null && log_success "hyprexpo enabled" || log_warning "hyprexpo enable failed"
    else
        log_warning "Could not add hyprland-plugins, hyprexpo will not be available"
    fi
else
    log_warning "hyprpm not available - hyprexpo plugin skipped"
    log_warning "You can install it later with: hyprpm add https://github.com/hyprwm/hyprland-plugins && hyprpm enable hyprexpo"
fi

# ============================================
# Step 8: Copy configuration files
# ============================================
echo -e "\n${GREEN}[8/8] Setting up configuration files...${NC}"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# AGS configuration
if [ -d "$SCRIPT_DIR/ags" ]; then
    mkdir -p ~/.config/ags/widgets ~/.config/ags/services ~/.config/ags/scss
    mkdir -p ~/.config/hyprmac  # For theme/color settings
    mkdir -p ~/.cache/hyprmac   # For dynamic color extraction cache
    cp -rf "$SCRIPT_DIR/ags/"* ~/.config/ags/ 2>/dev/null && log_success "AGS configuration" || log_error "Failed to copy AGS config"
else
    log_error "AGS config directory not found in $SCRIPT_DIR"
fi

# Hyprland configuration
if [ -d "$SCRIPT_DIR/hypr" ]; then
    mkdir -p ~/.config/hypr/scripts
    cp -f "$SCRIPT_DIR/hypr/hyprland.conf" ~/.config/hypr/hyprland.conf 2>/dev/null && log_success "hyprland.conf" || log_error "Failed to copy hyprland.conf"
    cp -f "$SCRIPT_DIR/hypr/hyprlock.conf" ~/.config/hypr/hyprlock.conf 2>/dev/null && log_success "hyprlock.conf" || log_warning "hyprlock.conf not found"
    if [ -f "$SCRIPT_DIR/hypr/wallpaper.sh" ]; then
        cp -f "$SCRIPT_DIR/hypr/wallpaper.sh" ~/.config/hypr/scripts/wallpaper.sh
        chmod +x ~/.config/hypr/scripts/wallpaper.sh
        log_success "wallpaper.sh"
    fi
else
    log_error "Hypr config directory not found in $SCRIPT_DIR"
fi

# Kitty configuration
if [ -d "$SCRIPT_DIR/kitty" ]; then
    mkdir -p ~/.config/kitty
    cp -f "$SCRIPT_DIR/kitty/kitty.conf" ~/.config/kitty/kitty.conf 2>/dev/null && log_success "kitty.conf" || log_warning "kitty.conf not found"
else
    log_warning "Kitty config directory not found"
fi

# Anyrun configuration (optional)
if [ -d "$SCRIPT_DIR/anyrun" ]; then
    mkdir -p ~/.config/anyrun
    cp -f "$SCRIPT_DIR/anyrun/config.ron" ~/.config/anyrun/config.ron 2>/dev/null
    cp -f "$SCRIPT_DIR/anyrun/style.css" ~/.config/anyrun/style.css 2>/dev/null
    log_success "Anyrun configuration (optional)"
fi

# SwayNC configuration
if [ -d "$SCRIPT_DIR/swaync" ]; then
    mkdir -p ~/.config/swaync
    cp -f "$SCRIPT_DIR/swaync/config.json" ~/.config/swaync/config.json 2>/dev/null && log_success "swaync config" || log_warning "swaync config not found"
    cp -f "$SCRIPT_DIR/swaync/style.css" ~/.config/swaync/style.css 2>/dev/null
else
    log_warning "SwayNC config directory not found"
fi

# Create wallpaper directory
mkdir -p ~/Pictures/wallpaper
log_success "Created wallpaper directory"

# ============================================
# Summary
# ============================================
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
if [ ${#ERRORS[@]} -eq 0 ]; then
    echo -e "${BLUE}║${NC}               ${GREEN}✓ Installation Complete!${NC}                   ${BLUE}║${NC}"
else
    echo -e "${BLUE}║${NC}          ${YELLOW}Installation Complete with Warnings${NC}            ${BLUE}║${NC}"
fi
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"

# Show errors if any
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}The following issues occurred (non-critical):${NC}"
    for err in "${ERRORS[@]}"; do
        echo -e "  ${RED}•${NC} $err"
    done
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Place a wallpaper at: ${BLUE}~/Pictures/wallpaper/current${NC}"
echo -e "  2. Restart Hyprland: ${BLUE}hyprctl dispatch exit${NC}"
echo -e "  3. Or reboot your system"
echo ""
echo -e "${YELLOW}Key Bindings:${NC}"
echo -e "  ${BLUE}Super + D${NC}     - Open Launcher (Spotlight)"
echo -e "  ${BLUE}Super + C${NC}     - Toggle Control Center"
echo -e "  ${BLUE}Super + S${NC}     - Mission Control (hyprexpo)"
echo -e "  ${BLUE}Super + L${NC}     - Lock Screen"
echo -e "  ${BLUE}Super + Q${NC}     - Close Window"
echo -e "  ${BLUE}Super + 1-9${NC}   - Switch Workspace"
echo ""
echo -e "${GREEN}Enjoy your macOS-like Hyprland desktop!${NC}"