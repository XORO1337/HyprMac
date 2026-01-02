// AGS (Advanced Gtk+ Sequencer) Configuration
// macOS Tahoe Widget System

import { App, Service, Utils, Widget } from './imports.js';
import Battery from './widgets/battery.js';
import Bluetooth from './widgets/bluetooth.js';
import Clock from './widgets/clock.js';
import ControlCenter from './widgets/control-center.js';
import Dock from './widgets/dock.js';
import Launchpad from './widgets/launchpad.js';
import Music from './widgets/music.js';
import Notes from './widgets/notes.js';
import Notifications from './widgets/notifications.js';
import Spotlight from './widgets/spotlight.js';
import Weather from './widgets/weather.js';
import AppleMenu from './widgets/apple-menu.js';
import MissionControl from './widgets/mission-control.js';
import DesktopWidgets from './widgets/desktop-widgets.js';

// Main application configuration
const config = {
    style: App.configDir + '/style.css',
    
    windows: [
        // Apple Menu
        AppleMenu(),
        
        // Spotlight Search
        Spotlight(),
        
        // Control Center
        ControlCenter(),
        
        // Notifications
        Notifications(),
        
        // Launchpad
        Launchpad(),
        
        // Mission Control
        MissionControl(),
        
        // Desktop Widgets
        DesktopWidgets(),
        
        // Dock (if not using external dock)
        Dock(),
    ],
    
    // Notification daemon
    notificationPopupHandler: (notification) => {
        return Notifications().handleNotification(notification);
    },
    
    // Close window on click outside
    closeWindowDelay: {
        'apple-menu': 100,
        'spotlight': 100,
        'control-center': 100,
        'notifications': 100,
        'launchpad': 200,
        'mission-control': 200,
    },
};

// Initialize services
Service.import('applications');
Service.import('audio');
Service.import('battery');
Service.import('bluetooth');
Service.import('network');
Service.import('notifications');
Service.import('systemtray');

// Export configuration
export default config;