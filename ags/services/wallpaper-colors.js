// Wallpaper Color Extraction Service for HyprMac
// Extracts dominant colors from wallpaper (image or video) and applies to theme

import Service from 'resource:///com/github/Aylur/ags/service.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';

// Config paths
const CONFIG_DIR = GLib.get_user_config_dir() + '/hyprmac';
const CACHE_DIR = GLib.get_user_cache_dir() + '/hyprmac';
const COLORS_FILE = CONFIG_DIR + '/colors.json';
const THUMBNAIL_FILE = CACHE_DIR + '/wallpaper_thumb.png';

// Default colors (Catppuccin Mocha)
const DEFAULT_COLORS = {
    primary: '#89b4fa',      // Blue accent
    secondary: '#cba6f7',    // Mauve
    tertiary: '#a6e3a1',     // Green
    background: '#1e1e2e',   // Base
    surface: '#313244',      // Surface0
    text: '#cdd6f4',         // Text
    subtext: '#a6adc8',      // Subtext0
};

class WallpaperColorService extends Service {
    static {
        Service.register(
            this,
            {
                'colors-changed': [],
            },
            {
                'colors': ['jsobject', 'r'],
                'wallpaper': ['string', 'rw'],
                'primary': ['string', 'r'],
                'secondary': ['string', 'r'],
                'tertiary': ['string', 'r'],
                'background': ['string', 'r'],
                'surface': ['string', 'r'],
                'text': ['string', 'r'],
                'dynamicEnabled': ['boolean', 'rw'],
            }
        );
    }

    #colors = { ...DEFAULT_COLORS };
    #wallpaper = '';

    get colors() { return this.#colors; }
    get primary() { return this.#colors.primary; }
    get secondary() { return this.#colors.secondary; }
    get tertiary() { return this.#colors.tertiary; }
    get background() { return this.#colors.background; }
    get surface() { return this.#colors.surface; }
    get text() { return this.#colors.text; }
    
    get wallpaper() { return this.#wallpaper; }
    
    set wallpaper(path) {
        if (!path || this.#wallpaper === path) return;
        this.#wallpaper = path;
        this.extractColors(path);
    }

    // Extract colors from wallpaper (image or video)
    async extractColors(wallpaperPath) {
        if (!wallpaperPath) return;
        
        // Ensure cache directory exists
        Utils.exec(`mkdir -p ${CACHE_DIR}`);
        Utils.exec(`mkdir -p ${CONFIG_DIR}`);
        
        const isVideo = /\.(mp4|webm|mkv|avi|mov)$/i.test(wallpaperPath);
        let imagePath = wallpaperPath;
        
        try {
            if (isVideo) {
                // Extract frame at 10 seconds using ffmpeg
                console.log(`Extracting frame from video: ${wallpaperPath}`);
                await Utils.execAsync([
                    'ffmpeg', '-y',
                    '-ss', '10',           // Seek to 10 seconds
                    '-i', wallpaperPath,
                    '-vframes', '1',       // Extract 1 frame
                    '-q:v', '2',           // High quality
                    THUMBNAIL_FILE
                ]);
                imagePath = THUMBNAIL_FILE;
                console.log(`Frame extracted to: ${THUMBNAIL_FILE}`);
            }
            
            // Extract colors using ImageMagick
            const colors = await this.#extractColorsFromImage(imagePath);
            
            if (colors) {
                this.#colors = colors;
                this.#saveColors();
                this.#generateCSS();
                this.emit('colors-changed');
                this.notify('colors');
                this.notify('primary');
                this.notify('secondary');
                this.notify('tertiary');
                this.notify('background');
                this.notify('surface');
                this.notify('text');
                console.log('Colors extracted and applied:', colors);
            }
        } catch (error) {
            console.error('Failed to extract colors:', error);
        }
    }

    // Extract dominant colors using ImageMagick
    async #extractColorsFromImage(imagePath) {
        try {
            // Get 6 dominant colors using ImageMagick
            const output = await Utils.execAsync([
                'convert', imagePath,
                '-resize', '100x100!',     // Resize for faster processing
                '-colors', '8',            // Reduce to 8 colors
                '-unique-colors',          // Get unique colors
                '-format', '%c',           // Output color info
                'histogram:info:-'
            ]);
            
            // Parse colors from output
            const colorMatches = output.matchAll(/#([0-9A-Fa-f]{6})/g);
            const extractedColors = [...colorMatches].map(m => '#' + m[1]);
            
            if (extractedColors.length < 3) {
                console.log('Not enough colors extracted, using defaults');
                return null;
            }
            
            // Sort colors by brightness
            const sortedColors = extractedColors.sort((a, b) => {
                return this.#getLuminance(a) - this.#getLuminance(b);
            });
            
            // Pick colors for different roles
            const darkest = sortedColors[0];
            const darkMid = sortedColors[Math.floor(sortedColors.length * 0.25)];
            const lightest = sortedColors[sortedColors.length - 1];
            
            // Find most saturated color for primary accent
            const mostSaturated = extractedColors.reduce((prev, curr) => {
                return this.#getSaturation(curr) > this.#getSaturation(prev) ? curr : prev;
            });
            
            // Find second most saturated for secondary
            const secondSaturated = extractedColors
                .filter(c => c !== mostSaturated)
                .reduce((prev, curr) => {
                    return this.#getSaturation(curr) > this.#getSaturation(prev) ? curr : prev;
                }, extractedColors[0]);
            
            // Calculate text color based on background luminance
            const bgLum = this.#getLuminance(darkest);
            const textColor = bgLum < 0.5 ? this.#lightenColor(lightest, 0.3) : this.#darkenColor(darkest, 0.3);
            const subtextColor = bgLum < 0.5 ? this.#lightenColor(lightest, 0.1) : this.#darkenColor(darkest, 0.1);
            
            return {
                primary: mostSaturated,
                secondary: secondSaturated,
                tertiary: this.#shiftHue(mostSaturated, 60),
                background: this.#darkenColor(darkest, 0.2),
                surface: darkMid,
                text: textColor,
                subtext: subtextColor,
            };
        } catch (error) {
            console.error('ImageMagick color extraction failed:', error);
            return null;
        }
    }

    // Get luminance of a color
    #getLuminance(hex) {
        const rgb = this.#hexToRgb(hex);
        return (0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b) / 255;
    }

    // Get saturation of a color
    #getSaturation(hex) {
        const rgb = this.#hexToRgb(hex);
        const max = Math.max(rgb.r, rgb.g, rgb.b);
        const min = Math.min(rgb.r, rgb.g, rgb.b);
        if (max === 0) return 0;
        return (max - min) / max;
    }

    // Convert hex to RGB
    #hexToRgb(hex) {
        const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : { r: 0, g: 0, b: 0 };
    }

    // Convert RGB to hex
    #rgbToHex(r, g, b) {
        return '#' + [r, g, b].map(x => {
            const hex = Math.max(0, Math.min(255, Math.round(x))).toString(16);
            return hex.length === 1 ? '0' + hex : hex;
        }).join('');
    }

    // Lighten a color
    #lightenColor(hex, amount) {
        const rgb = this.#hexToRgb(hex);
        return this.#rgbToHex(
            rgb.r + (255 - rgb.r) * amount,
            rgb.g + (255 - rgb.g) * amount,
            rgb.b + (255 - rgb.b) * amount
        );
    }

    // Darken a color
    #darkenColor(hex, amount) {
        const rgb = this.#hexToRgb(hex);
        return this.#rgbToHex(
            rgb.r * (1 - amount),
            rgb.g * (1 - amount),
            rgb.b * (1 - amount)
        );
    }

    // Shift hue of a color
    #shiftHue(hex, degrees) {
        const rgb = this.#hexToRgb(hex);
        const hsl = this.#rgbToHsl(rgb.r, rgb.g, rgb.b);
        hsl.h = (hsl.h + degrees) % 360;
        const newRgb = this.#hslToRgb(hsl.h, hsl.s, hsl.l);
        return this.#rgbToHex(newRgb.r, newRgb.g, newRgb.b);
    }

    // RGB to HSL
    #rgbToHsl(r, g, b) {
        r /= 255; g /= 255; b /= 255;
        const max = Math.max(r, g, b), min = Math.min(r, g, b);
        let h, s, l = (max + min) / 2;
        
        if (max === min) {
            h = s = 0;
        } else {
            const d = max - min;
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
            switch (max) {
                case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
                case g: h = ((b - r) / d + 2) / 6; break;
                case b: h = ((r - g) / d + 4) / 6; break;
            }
            h *= 360;
        }
        return { h, s, l };
    }

    // HSL to RGB
    #hslToRgb(h, s, l) {
        let r, g, b;
        h /= 360;
        
        if (s === 0) {
            r = g = b = l;
        } else {
            const hue2rgb = (p, q, t) => {
                if (t < 0) t += 1;
                if (t > 1) t -= 1;
                if (t < 1/6) return p + (q - p) * 6 * t;
                if (t < 1/2) return q;
                if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
                return p;
            };
            const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
            const p = 2 * l - q;
            r = hue2rgb(p, q, h + 1/3);
            g = hue2rgb(p, q, h);
            b = hue2rgb(p, q, h - 1/3);
        }
        return { r: r * 255, g: g * 255, b: b * 255 };
    }

    // Save colors to file
    #saveColors() {
        try {
            Utils.writeFile(JSON.stringify(this.#colors, null, 2), COLORS_FILE);
        } catch (e) {
            console.error('Failed to save colors:', e);
        }
    }

    // Load saved colors
    #loadColors() {
        try {
            const content = Utils.readFile(COLORS_FILE);
            const colors = JSON.parse(content);
            if (colors && colors.primary) {
                this.#colors = colors;
                this.#generateCSS();
            }
        } catch {
            // Use defaults
        }
    }

    // Generate dynamic CSS with extracted colors
    #generateCSS() {
        const css = `
/* HyprMac Dynamic Colors - Auto-generated from wallpaper */
/* DO NOT EDIT - This file is regenerated when wallpaper changes */

/* Dynamic color variables applied via classes */
.dynamic-colors,
.dynamic-colors.dark,
.dynamic-colors.light {
    /* These colors are extracted from wallpaper */
}

/* Dark theme with dynamic colors */
.dark.dynamic-colors .bar-container {
    background: alpha(${this.#colors.background}, 0.85);
}

.dark.dynamic-colors .dock {
    background: alpha(${this.#colors.background}, 0.8);
}

.dark.dynamic-colors .control-center {
    background: alpha(${this.#colors.background}, 0.9);
}

.dark.dynamic-colors .launcher {
    background: alpha(${this.#colors.background}, 0.95);
}

.dark.dynamic-colors .notification {
    background: alpha(${this.#colors.background}, 0.95);
}

.dark.dynamic-colors .osd {
    background: alpha(${this.#colors.background}, 0.9);
}

/* Accent colors */
.dark.dynamic-colors .workspace-btn.active {
    background: alpha(${this.#colors.primary}, 0.3);
    color: ${this.#colors.primary};
}

.dark.dynamic-colors .cc-toggle.active {
    background: ${this.#colors.primary};
}

.dark.dynamic-colors .cc-slider trough highlight {
    background: ${this.#colors.primary};
}

.dark.dynamic-colors .cc-perf-btn.active {
    background: ${this.#colors.primary};
}

.dark.dynamic-colors .launcher-item:focus {
    background: ${this.#colors.primary};
}

.dark.dynamic-colors .notification-action:hover {
    background: ${this.#colors.primary};
}

/* Text colors */
.dark.dynamic-colors .apple-menu,
.dark.dynamic-colors .active-app,
.dark.dynamic-colors .clock,
.dark.dynamic-colors .cc-title,
.dark.dynamic-colors .media-title,
.dark.dynamic-colors .launcher-item-name,
.dark.dynamic-colors .notification-title {
    color: ${this.#colors.text};
}

.dark.dynamic-colors .workspace-btn,
.dark.dynamic-colors .cc-section-label,
.dark.dynamic-colors .toggle-label,
.dark.dynamic-colors .media-artist,
.dark.dynamic-colors .launcher-item-desc,
.dark.dynamic-colors .notification-body {
    color: ${this.#colors.subtext};
}

/* Surface colors */
.dark.dynamic-colors .cc-toggle {
    background: ${this.#colors.surface};
}

.dark.dynamic-colors .cc-sliders,
.dark.dynamic-colors .cc-performance,
.dark.dynamic-colors .cc-media {
    background: ${this.#colors.surface};
}

.dark.dynamic-colors .cc-perf-btn {
    background: ${this.#lightenColor(this.#colors.surface, 0.1)};
}

.dark.dynamic-colors .launcher-search {
    background: ${this.#colors.surface};
}

.dark.dynamic-colors .dock-separator {
    background: ${this.#colors.subtext};
}

.dark.dynamic-colors .dock-indicator.running {
    background: ${this.#colors.primary};
}

/* Light theme with dynamic colors */
.light.dynamic-colors .bar-container {
    background: alpha(${this.#lightenColor(this.#colors.background, 0.8)}, 0.85);
}

.light.dynamic-colors .dock {
    background: alpha(${this.#lightenColor(this.#colors.background, 0.8)}, 0.85);
}

.light.dynamic-colors .control-center {
    background: alpha(${this.#lightenColor(this.#colors.background, 0.8)}, 0.92);
}

.light.dynamic-colors .launcher {
    background: alpha(${this.#lightenColor(this.#colors.background, 0.8)}, 0.95);
}

.light.dynamic-colors .workspace-btn.active {
    background: alpha(${this.#colors.primary}, 0.3);
    color: ${this.#darkenColor(this.#colors.primary, 0.2)};
}

.light.dynamic-colors .cc-toggle.active {
    background: ${this.#colors.primary};
}

.light.dynamic-colors .cc-slider trough highlight {
    background: ${this.#colors.primary};
}

.light.dynamic-colors .cc-perf-btn.active {
    background: ${this.#colors.primary};
}

.light.dynamic-colors .apple-menu,
.light.dynamic-colors .active-app,
.light.dynamic-colors .clock,
.light.dynamic-colors .cc-title,
.light.dynamic-colors .media-title {
    color: ${this.#darkenColor(this.#colors.text, 0.6)};
}
`;
        
        // Write dynamic CSS file
        const cssPath = App.configDir + '/dynamic-colors.css';
        try {
            Utils.writeFile(css, cssPath);
            // Apply the CSS
            App.applyCss(cssPath);
            console.log('Dynamic colors CSS applied');
        } catch (e) {
            console.error('Failed to write dynamic CSS:', e);
        }
    }

    // Reset to default colors
    resetColors() {
        this.#colors = { ...DEFAULT_COLORS };
        this.#saveColors();
        this.#generateCSS();
        this.emit('colors-changed');
    }

    // Enable/disable dynamic colors
    #dynamicEnabled = false;
    
    get dynamicEnabled() { return this.#dynamicEnabled; }
    
    set dynamicEnabled(value) {
        if (this.#dynamicEnabled === value) return;
        this.#dynamicEnabled = value;
        // Toggle dynamic-colors class on all widgets
        this.emit('colors-changed');
        this.notify('dynamicEnabled');
    }

    toggleDynamic() {
        this.dynamicEnabled = !this.#dynamicEnabled;
    }

    constructor() {
        super();
        
        // Ensure directories exist
        Utils.exec(`mkdir -p ${CACHE_DIR}`);
        Utils.exec(`mkdir -p ${CONFIG_DIR}`);
        
        // Load saved colors
        this.#loadColors();
        
        // Watch for wallpaper changes via swww
        this.#watchWallpaper();
    }

    // Watch for wallpaper changes
    #watchWallpaper() {
        // Check current swww wallpaper periodically
        Utils.interval(5000, () => {
            Utils.execAsync(['swww', 'query'])
                .then(output => {
                    // Parse swww output for current wallpaper path
                    const match = output.match(/image: (.+)/);
                    if (match && match[1] && match[1] !== this.#wallpaper) {
                        this.wallpaper = match[1].trim();
                    }
                })
                .catch(() => {});
        });
    }
}

// Singleton export
const service = new WallpaperColorService();
export default service;
