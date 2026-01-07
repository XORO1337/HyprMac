// macOS-style Dock
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Applications from 'resource:///com/github/Aylur/ags/service/applications.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Theme from '../services/theme.js';
import WallpaperColors from '../services/wallpaper-colors.js';

// Default dock apps
const DOCK_APPS = [
    'org.gnome.Nautilus',
    'firefox',
    'google-chrome',
    'chromium',
    'code',
    'kitty',
    'spotify',
    'discord',
    'slack',
    'org.gnome.Settings',
];

// Check if app is running
const isRunning = (appClass) => {
    const clients = Hyprland.clients;
    return clients.some(c => 
        c.class.toLowerCase().includes(appClass.toLowerCase()) ||
        c.initialClass.toLowerCase().includes(appClass.toLowerCase())
    );
};

// Dock Item
const DockItem = (app) => {
    const appName = app.name;
    const appClass = app.app.get_string('StartupWMClass') || app.name;
    
    return Widget.Button({
        className: 'dock-item',
        tooltip_text: appName,
        onClicked: () => {
            app.launch();
        },
        onSecondaryClick: (self, event) => {
            // Right-click menu
            const menu = Widget.Menu({
                children: [
                    Widget.MenuItem({
                        child: Widget.Label({ label: 'New Window' }),
                        onActivate: () => app.launch(),
                    }),
                    Widget.MenuItem({
                        child: Widget.Label({ label: 'Force Quit' }),
                        onActivate: () => {
                            Utils.execAsync(`hyprctl dispatch killactive`);
                        },
                    }),
                ],
            });
            menu.popup_at_pointer(event);
        },
        child: Widget.Box({
            className: 'dock-item-box',
            vertical: true,
            children: [
                Widget.Icon({
                    icon: app.icon_name || 'application-x-executable',
                    size: 48,
                }),
                // Running indicator dot
                Widget.Box({
                    className: 'dock-indicator',
                    setup: self => {
                        const update = () => self.toggleClassName('running', isRunning(appClass));
                        self.hook(Hyprland, update, 'client-added');
                        self.hook(Hyprland, update, 'client-removed');
                    },
                }),
            ],
        }),
        // Hover animation via CSS
        setup: self => {
            self.connect('enter-notify-event', () => {
                self.toggleClassName('hovered', true);
            });
            self.connect('leave-notify-event', () => {
                self.toggleClassName('hovered', false);
            });
        },
    });
};

// Separator
const Separator = () => Widget.Box({
    className: 'dock-separator',
    css: 'min-width: 1px; min-height: 48px; margin: 0 8px;',
});

// Trash (optional macOS-like)
const Trash = () => Widget.Button({
    className: 'dock-item dock-trash',
    tooltip_text: 'Trash',
    child: Widget.Icon({
        icon: 'user-trash-symbolic',
        size: 48,
    }),
    onClicked: () => Utils.execAsync('nautilus trash:///'),
});

// Build dock items
const DockItems = () => Widget.Box({
    className: 'dock-items',
    children: Applications.bind('list').as(apps => {
        const dockApps = DOCK_APPS
            .map(name => apps.find(app => 
                app.desktop?.includes(name) || 
                app.name.toLowerCase().includes(name.toLowerCase()) ||
                app.icon_name?.toLowerCase().includes(name.toLowerCase())
            ))
            .filter(Boolean)
            .map(app => DockItem(app));
        
        return [
            ...dockApps,
            Separator(),
            Trash(),
        ];
    }),
});

// Main Dock
export const Dock = (monitor = 0) => Widget.Window({
    name: 'dock',
    monitor,
    anchor: ['bottom'],
    exclusivity: 'exclusive',
    className: 'dock-window',
    child: Widget.Box({
        className: 'dock',
        setup: self => {
            self.hook(Theme, () => {
                self.toggleClassName('dark', Theme.isDark);
                self.toggleClassName('light', !Theme.isDark);
            });
            self.hook(WallpaperColors, () => {
                self.toggleClassName('dynamic-colors', WallpaperColors.dynamicEnabled);
            });
        },
        child: DockItems(),
    }),
});
