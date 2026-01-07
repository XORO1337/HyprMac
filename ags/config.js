// HyprMac - macOS-style AGS Configuration for Hyprland
// Main entry point

import Gdk from 'gi://Gdk';
import App from 'resource:///com/github/Aylur/ags/app.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

// Import widgets
import { Bar } from './widgets/bar.js';
import { Dock } from './widgets/dock.js';
import { ControlCenter } from './widgets/controlcenter.js';
import { NotificationPopups } from './widgets/notifications.js';
import { Launcher } from './widgets/launcher.js';
import { OSD } from './widgets/osd.js';
import { WallpaperPicker } from './widgets/wallpaper-picker.js';

// Import theme service
import Theme from './services/theme.js';

// Get all monitors
const display = Gdk.Display.get_default();

// Compile SCSS if sass is available, otherwise use CSS
const compileSCSS = () => {
    const scss = `${App.configDir}/scss/main.scss`;
    const css = `${App.configDir}/style.css`;
    
    // Try to compile SCSS (synchronous)
    try {
        Utils.exec(`sassc ${scss} ${css}`);
        console.log('SCSS compiled with sassc');
    } catch {
        try {
            Utils.exec(`sass ${scss} ${css} --no-source-map`);
            console.log('SCSS compiled with sass');
        } catch {
            // If both fail, just use existing CSS
            console.log('SCSS compilation failed, using existing CSS');
        }
    }
    
    return css;
};

// Export configuration
export default {
    style: compileSCSS(),
    
    windows: [
        // Top Bar on each monitor
        ...Array.from({ length: display?.get_n_monitors() || 1 }, (_, i) => Bar(i)),
        
        // Dock (bottom, primary monitor only)
        Dock(0),
        
        // Control Center (toggleable)
        ControlCenter(),
        
        // Notification popups
        NotificationPopups(),
        
        // App Launcher (Spotlight-like)
        Launcher(),
        
        // OSD for volume/brightness
        OSD(),
        
        // Wallpaper Picker
        WallpaperPicker(),
    ],
};
