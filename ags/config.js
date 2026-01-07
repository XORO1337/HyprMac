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

// Get all monitors
const display = Gdk.Display.get_default();

// Export configuration
export default {
    style: App.configDir + '/style.css',
    
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
    ],
};
