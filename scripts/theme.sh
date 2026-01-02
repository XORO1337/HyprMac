#!/bin/bash

# macOS Tahoe Theme Installation Script
# Installs and applies the macOS theme components

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
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
FONT_DIR="$HOME/.fonts"

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

# Function to install theme dependencies
install_theme_deps() {
    print_status "Installing theme dependencies..."
    
    sudo pacman -S --needed --noconfirm \
        gtk-engine-murrine \
        gtk-engines \
        sassc \
        optipng \
        inkscape \
        imagemagick \
        librsvg \
        lxappearance \
        gtk-theme-config \
        qt5ct \
        qt6ct \
        kvantum-qt5 \
        kvantum-qt6 \
        papirus-icon-theme
    
    print_success "Theme dependencies installed"
}

# Function to install macOS Tahoe GTK theme
install_gtk_theme() {
    print_status "Installing macOS Tahoe GTK theme..."
    
    if [ ! -d "$THEME_DIR/macos-tahoe-gtk-theme" ]; then
        cd /tmp
        git clone https://github.com/vinceliuice/macos-tahoe-gtk-theme.git
        cd macos-tahoe-gtk-theme
        
        # Install theme
        ./install.sh -d "$THEME_DIR"
        
        # Clean up
        cd /tmp
        rm -rf macos-tahoe-gtk-theme
        
        print_success "macOS Tahoe GTK theme installed"
    else
        print_status "macOS Tahoe GTK theme already installed"
    fi
}

# Function to install macOS Tahoe icons
install_icon_theme() {
    print_status "Installing macOS Tahoe icon theme..."
    
    if [ ! -d "$ICON_DIR/macos-tahoe-icon-theme" ]; then
        cd /tmp
        git clone https://github.com/vinceliuice/macos-tahoe-icon-theme.git
        cd macos-tahoe-icon-theme
        
        # Install icons
        ./install.sh -d "$ICON_DIR"
        
        # Clean up
        cd /tmp
        rm -rf macos-tahoe-icon-theme
        
        print_success "macOS Tahoe icon theme installed"
    else
        print_status "macOS Tahoe icon theme already installed"
    fi
}

# Function to install macOS cursors
install_cursor_theme() {
    print_status "Installing macOS cursor theme..."
    
    if [ ! -d "$ICON_DIR/macOS" ]; then
        cd /tmp
        git clone https://github.com/vinceliuice/macOS-cursors.git
        cd macOS-cursors
        
        # Install cursors
        ./install.sh -d "$ICON_DIR"
        
        # Clean up
        cd /tmp
        rm -rf macOS-cursors
        
        print_success "macOS cursor theme installed"
    else
        print_status "macOS cursor theme already installed"
    fi
}

# Function to install San Francisco fonts
install_sf_fonts() {
    print_status "Installing San Francisco fonts..."
    
    if [ ! -d "$FONT_DIR/SF-Pro" ]; then
        cd /tmp
        
        # Clone SF fonts repository
        git clone https://github.com/AppleDesignResources/SanFranciscoFont.git
        cd SanFranciscoFont
        
        # Create font directory
        mkdir -p "$FONT_DIR/SF-Pro"
        
        # Copy fonts
        cp *.ttf "$FONT_DIR/SF-Pro/" 2>/dev/null || true
        
        # Update font cache
        fc-cache -fv
        
        # Clean up
        cd /tmp
        rm -rf SanFranciscoFont
        
        print_success "San Francisco fonts installed"
    else
        print_status "San Francisco fonts already installed"
    fi
}

# Function to install additional fonts
install_additional_fonts() {
    print_status "Installing additional fonts..."
    
    # Install nerd fonts and other useful fonts
    yay -S --needed --noconfirm \
        nerd-fonts-complete \
        ttf-meslo-nerd-font-powerlevel10k \
        ttf-fira-code \
        ttf-jetbrains-mono \
        ttf-cascadia-code \
        ttf-hack \
        ttf-iosevka-nerd \
        noto-fonts-emoji \
        ttf-twemoji \
        ttf-emojione-color
    
    # Update font cache
    fc-cache -fv
    
    print_success "Additional fonts installed"
}

# Function to apply GTK theme
apply_gtk_theme() {
    print_status "Applying GTK theme..."
    
    # Apply GTK theme using gsettings (GNOME/GTK)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme 'macOS-Tahoe' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme 'macOS-Tahoe' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme 'macOS' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface font-name 'SF Pro Display 11' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface monospace-font-name 'SF Mono 11' 2>/dev/null || true
    fi
    
    # Apply GTK theme using lxappearance (LXDE/XFCE)
    if command -v lxappearance &> /dev/null; then
        # Create lxappearance config
        mkdir -p "$CONFIG_DIR/gtk-3.0"
        cat > "$CONFIG_DIR/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=macOS-Tahoe
gtk-icon-theme-name=macOS-Tahoe
gtk-font-name=SF Pro Display 11
gtk-cursor-theme-name=macOS
gtk-cursor-theme-size=24
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
EOF
    fi
    
    # Apply GTK2 theme
    mkdir -p "$HOME/.gtkrc-2.0"
    cat > "$HOME/.gtkrc-2.0" << 'EOF'
gtk-theme-name="macOS-Tahoe"
gtk-icon-theme-name="macOS-Tahoe"
gtk-font-name="SF Pro Display 11"
gtk-cursor-theme-name="macOS"
gtk-cursor-theme-size=24
EOF
    
    print_success "GTK theme applied"
}

# Function to apply Qt theme
apply_qt_theme() {
    print_status "Applying Qt theme..."
    
    # Qt5 configuration
    mkdir -p "$CONFIG_DIR/qt5ct"
    cat > "$CONFIG_DIR/qt5ct/qt5ct.conf" << 'EOF'
[Appearance]
color_scheme_path=
custom_palette=false
icon_theme=macOS-Sierra
standard_dialogs=default
style=gtk2

[Fonts]
fixed=SF Mono 11
general=SF Pro Display 11

[Interface]
activate_item_on_single_click=0
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_layout=0
double_click_interval=400
gui_effects=0
show_shortcuts_in_context_menus=1
stylesheets=/usr/share/qt5ct/
EOF
    
    # Qt6 configuration
    mkdir -p "$CONFIG_DIR/qt6ct"
    cat > "$CONFIG_DIR/qt6ct/qt6ct.conf" << 'EOF'
[Appearance]
color_scheme_path=
custom_palette=false
icon_theme=macOS-Sierra
standard_dialogs=default
style=gtk2

[Fonts]
fixed=SF Mono 11
general=SF Pro Display 11

[Interface]
activate_item_on_single_click=0
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_layout=0
double_click_interval=400
gui_effects=0
show_shortcuts_in_context_menus=1
stylesheets=/usr/share/qt6ct/
EOF
    
    # Kvantum configuration
    mkdir -p "$CONFIG_DIR/Kvantum"
    cat > "$CONFIG_DIR/Kvantum/kvantum.kvconfig" << 'EOF'
[General]
theme=macOS-Sierra
EOF
    
    # Environment variables for Qt
    echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> "$HOME/.profile"
    echo 'export QT_STYLE_OVERRIDE=kvantum' >> "$HOME/.profile"
    
    print_success "Qt theme applied"
}

# Function to apply window manager theme
apply_wm_theme() {
    print_status "Applying window manager theme..."
    
    # Hyprland theme settings (already in hyprland.conf)
    # This function can be extended for other WMs
    
    # Create .Xresources for X11 applications
    cat > "$HOME/.Xresources" << 'EOF'
! macOS Tahoe X11 Resources

! Colors
*background: #1e1e1e
*foreground: #d4d4d4

! Fonts
*font: -*-sf pro display-medium-r-*-*-11-*-*-*-*-*-*-*
*faceName: SF Pro Display
*faceSize: 11

! Cursor
Xcursor.theme: macOS
Xcursor.size: 24
EOF
    
    # Apply X11 resources
    if command -v xrdb &> /dev/null; then
        xrdb -merge "$HOME/.Xresources"
    fi
    
    print_success "Window manager theme applied"
}

# Function to create theme configuration files
create_theme_configs() {
    print_status "Creating theme configuration files..."
    
    # GTK theme configuration
    mkdir -p "$CONFIG_DIR/gtk-3.0"
    cat > "$CONFIG_DIR/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=macOS-Tahoe
gtk-icon-theme-name=macOS-Tahoe
gtk-font-name=SF Pro Display 11
gtk-cursor-theme-name=macOS
gtk-cursor-theme-size=24
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=0
EOF
    
    # Create color scheme file
    mkdir -p "$CONFIG_DIR/gtk-3.0/colors"
    cat > "$CONFIG_DIR/gtk-3.0/colors/macos-tahoe.css" << 'EOF'
/* macOS Tahoe Color Scheme */

@define-color theme_bg_color #ffffff;
@define-color theme_fg_color #1d1d1f;
@define-color theme_base_color #ffffff;
@define-color theme_text_color #1d1d1f;
@define-color theme_selected_bg_color #007AFF;
@define-color theme_selected_fg_color #ffffff;
@define-color theme_tooltip_bg_color #2c2c2e;
@define-color theme_tooltip_fg_color #ffffff;
@define-color theme_view_bg_color #ffffff;
@define-color theme_view_fg_color #1d1d1f;
@define-color theme_view_hover_bg_color #f2f2f7;
@define-color theme_view_selected_bg_color #007AFF;
@define-color theme_view_selected_fg_color #ffffff;
@define-color theme_button_bg_color #f2f2f7;
@define-color theme_button_fg_color #1d1d1f;
@define-color theme_button_hover_bg_color #e5e5ea;
@define-color theme_button_active_bg_color #d1d1d6;
@define-color theme_entry_bg_color #f2f2f7;
@define-color theme_entry_fg_color #1d1d1f;
@define-color theme_entry_border_color #d1d1d6;
EOF
    
    print_success "Theme configuration files created"
}

# Function to setup environment variables
setup_environment() {
    print_status "Setting up environment variables..."
    
    # Add to .profile
    cat >> "$HOME/.profile" << 'EOF'

# macOS Tahoe Environment Variables
export GTK_THEME=macOS-Tahoe
export ICON_THEME=macOS-Tahoe
export CURSOR_THEME=macOS
export FONT_NAME="SF Pro Display 11"
export MONOSPACE_FONT_NAME="SF Mono 11"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
export ELECTRON_OZONE_PLATFORM_HINT=auto
EOF
    
    # Add to .bashrc
    cat >> "$HOME/.bashrc" << 'EOF'

# macOS Tahoe Environment Variables
export GTK_THEME=macOS-Tahoe
export ICON_THEME=macOS-Tahoe
export CURSOR_THEME=macOS
export FONT_NAME="SF Pro Display 11"
export MONOSPACE_FONT_NAME="SF Mono 11"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
EOF
    
    # Add to .zshrc
    cat >> "$HOME/.zshrc" << 'EOF'

# macOS Tahoe Environment Variables
export GTK_THEME=macOS-Tahoe
export ICON_THEME=macOS-Tahoe
export CURSOR_THEME=macOS
export FONT_NAME="SF Pro Display 11"
export MONOSPACE_FONT_NAME="SF Mono 11"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
EOF
    
    print_success "Environment variables configured"
}

# Function to apply theme immediately
apply_theme_now() {
    print_status "Applying theme immediately..."
    
    # Reload GTK theme
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme 'macOS-Sierra' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme 'macOS-Sierra' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme 'macOS' 2>/dev/null || true
    fi
    
    # Update font cache
    fc-cache -fv
    
    # Send theme change signal to applications
    pkill -USR1 -x gtk3-demo 2>/dev/null || true
    pkill -USR1 -x gtk4-demo 2>/dev/null || true
    
    print_success "Theme applied immediately"
}

# Function to create theme preview
create_theme_preview() {
    print_status "Creating theme preview..."
    
    # Create a simple HTML preview
    cat > "$PROJECT_ROOT/docs/theme-preview.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>macOS Tahoe Theme Preview</title>
    <style>
        body {
            font-family: 'SF Pro Display', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #1d1d1f;
            margin: 0;
            padding: 40px;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        h1 {
            font-size: 32px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #1d1d1f;
        }
        .section {
            margin-bottom: 30px;
        }
        .section h2 {
            font-size: 24px;
            font-weight: 500;
            margin-bottom: 15px;
            color: #1d1d1f;
        }
        .color-swatch {
            display: inline-block;
            width: 50px;
            height: 50px;
            border-radius: 8px;
            margin: 5px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        .button {
            background: #007AFF;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            margin: 5px;
        }
        .button:hover {
            background: #0056CC;
        }
        .card {
            background: rgba(255, 255, 255, 0.7);
            border-radius: 12px;
            padding: 20px;
            margin: 10px 0;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>macOS Tahoe Theme Preview</h1>
        
        <div class="section">
            <h2>Color Palette</h2>
            <div class="color-swatch" style="background: #007AFF;" title="Accent Blue"></div>
            <div class="color-swatch" style="background: #1d1d1f;" title="Text Primary"></div>
            <div class="color-swatch" style="background: #f2f2f7;" title="Background Secondary"></div>
            <div class="color-swatch" style="background: #e5e5ea;" title="Border"></div>
            <div class="color-swatch" style="background: #34c759;" title="Success Green"></div>
            <div class="color-swatch" style="background: #ff9500;" title="Warning Orange"></div>
            <div class="color-swatch" style="background: #ff3b30;" title="Error Red"></div>
        </div>
        
        <div class="section">
            <h2>Typography</h2>
            <p style="font-size: 24px; font-weight: 600;">SF Pro Display - Large Title</p>
            <p style="font-size: 20px; font-weight: 500;">SF Pro Display - Title</p>
            <p style="font-size: 17px; font-weight: 400;">SF Pro Display - Body</p>
            <p style="font-size: 15px; font-weight: 400; opacity: 0.7;">SF Pro Display - Caption</p>
            <p style="font-family: 'SF Mono', monospace; font-size: 14px;">SF Mono - Code</p>
        </div>
        
        <div class="section">
            <h2>Components</h2>
            <div class="card">
                <h3>Card Component</h3>
                <p>This is how cards will appear in the interface.</p>
                <button class="button">Primary Button</button>
                <button class="button" style="background: #34c759;">Success Button</button>
            </div>
        </div>
        
        <div class="section">
            <h2>Theme Applied Successfully!</h2>
            <p>The macOS Tahoe theme has been installed and configured. Restart your applications to see the changes.</p>
        </div>
    </div>
</body>
</html>
EOF
    
    print_success "Theme preview created"
}

# Function to print completion message
print_completion() {
    print_success "Theme installation completed!"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  macOS Tahoe Theme - Installation Complete${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${YELLOW}Installed Components:${NC}"
    echo -e "- GTK Theme: ${GREEN}macOS-Sierra${NC}"
    echo -e "- Icon Theme: ${GREEN}macOS-Sierra${NC}"
    echo -e "- Cursor Theme: ${GREEN}macOS${NC}"
    echo -e "- Fonts: ${GREEN}SF Pro Display, SF Mono${NC}"
    echo
    echo -e "${YELLOW}Configuration Files:${NC}"
    echo -e "- GTK3: ${GREEN}$CONFIG_DIR/gtk-3.0/settings.ini${NC}"
    echo -e "- GTK2: ${GREEN}$HOME/.gtkrc-2.0${NC}"
    echo -e "- Qt5: ${GREEN}$CONFIG_DIR/qt5ct/qt5ct.conf${NC}"
    echo -e "- Qt6: ${GREEN}$CONFIG_DIR/qt6ct/qt6ct.conf${NC}"
    echo -e "- Kvantum: ${GREEN}$CONFIG_DIR/Kvantum/kvantum.kvconfig${NC}"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "1. Log out and log back in to see all changes"
    echo -e "2. Run ${GREEN}lxappearance${NC} to fine-tune GTK settings"
    echo -e "3. Run ${GREEN}qt5ct${NC} to configure Qt5 applications"
    echo -e "4. Open ${GREEN}$PROJECT_ROOT/docs/theme-preview.html${NC} to see preview"
    echo
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "- If fonts don't appear, run: ${GREEN}fc-cache -fv${NC}"
    echo -e "- If theme doesn't apply, check: ${GREEN}echo $GTK_THEME${NC}"
    echo -e "- For Qt applications, ensure ${GREEN}qt5ct${NC} is installed"
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

# Main theme installation function
main() {
    print_status "Starting macOS Tahoe theme installation..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_error "Run as regular user with sudo privileges."
        exit 1
    fi
    
    # Check if running on Arch Linux
    check_arch_linux
    
    # Install theme components
    install_theme_deps
    install_gtk_theme
    install_icon_theme
    install_cursor_theme
    install_sf_fonts
    install_additional_fonts
    
    # Apply themes
    apply_gtk_theme
    apply_qt_theme
    apply_wm_theme
    
    # Setup configurations
    create_theme_configs
    setup_environment
    
    # Apply theme immediately
    apply_theme_now
    
    # Create theme preview
    create_theme_preview
    
    print_completion
}

# Run main function
main "$@"