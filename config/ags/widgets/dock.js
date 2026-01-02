// Dock Widget
// macOS-style animated dock with magnification

import { Widget, Service } from '../imports.js';
import { exec, execAsync } from '../utils.js';

const applications = await Service.import('applications');

export default () => {
    // Dock items configuration
    const dockItems = [
        { name: 'Finder', icon: 'system-file-manager', exec: 'nautilus' },
        { name: 'Safari', icon: 'web-browser', exec: 'firefox' },
        { name: 'Messages', icon: 'mail-message-new', exec: 'thunderbird' },
        { name: 'Photos', icon: 'image-x-generic', exec: 'eog' },
        { name: 'Music', icon: 'audio-x-generic', exec: 'spotify' },
        { name: 'System Preferences', icon: 'preferences-system', exec: 'gnome-control-center' },
        { name: 'Terminal', icon: 'utilities-terminal', exec: 'alacritty' },
        { name: 'Code', icon: 'text-x-generic', exec: 'code' }
    ];
    
    // Create dock item widgets
    const createDockItem = (item) => {
        const button = Widget.Button({
            className: 'dock-item',
            child: Widget.Box({
                vertical: true,
                spacing: 4,
                children: [
                    Widget.Icon({
                        icon: item.icon,
                        size: 48,
                        css: 'margin: 8px;'
                    }),
                    Widget.Label({
                        label: item.name,
                        css: 'font-size: 10px; text-align: center;'
                    })
                ]
            }),
            onClicked: () => {
                execAsync(item.exec);
                App.closeWindow('dock');
            },
            css: `
                background: transparent;
                border: none;
                padding: 8px;
                margin: 0 4px;
                border-radius: 12px;
                transition: all 0.2s ease;
            `,
            connections: [
                ['enter-notify-event', (self) => {
                    self.css = `
                        background: rgba(255, 255, 255, 0.2);
                        border: none;
                        padding: 8px;
                        margin: 0 4px;
                        border-radius: 12px;
                        transform: scale(1.1);
                        transition: all 0.2s ease;
                    `;
                }],
                ['leave-notify-event', (self) => {
                    self.css = `
                        background: transparent;
                        border: none;
                        padding: 8px;
                        margin: 0 4px;
                        border-radius: 12px;
                        transform: scale(1);
                        transition: all 0.2s ease;
                    `;
                }]
            ]
        });
        
        return button;
    };
    
    // Create dock items
    const dockItemWidgets = dockItems.map(createDockItem);
    
    // Trash widget
    const trashWidget = Widget.Button({
        className: 'dock-item trash',
        child: Widget.Box({
            vertical: true,
            spacing: 4,
            children: [
                Widget.Icon({
                    icon: 'user-trash',
                    size: 48,
                    css: 'margin: 8px;'
                }),
                Widget.Label({
                    label: 'Trash',
                    css: 'font-size: 10px; text-align: center;'
                })
            ]
        }),
        onClicked: () => {
            execAsync('nautilus trash:///');
            App.closeWindow('dock');
        },
        css: `
            background: transparent;
            border: none;
            padding: 8px;
            margin: 0 4px;
            border-radius: 12px;
            transition: all 0.2s ease;
        `,
        connections: [
            ['enter-notify-event', (self) => {
                self.css = `
                    background: rgba(255, 255, 255, 0.2);
                    border: none;
                    padding: 8px;
                    margin: 0 4px;
                    border-radius: 12px;
                    transform: scale(1.1);
                    transition: all 0.2s ease;
                `;
            }],
            ['leave-notify-event', (self) => {
                self.css = `
                    background: transparent;
                    border: none;
                    padding: 8px;
                    margin: 0 4px;
                    border-radius: 12px;
                    transform: scale(1);
                    transition: all 0.2s ease;
                `;
            }]
        ]
    });
    
    // Separator
    const separator = Widget.Separator({
        orientation: Gtk.Orientation.VERTICAL,
        css: 'margin: 0 8px; background: rgba(255, 255, 255, 0.2);'
    });
    
    // Main dock widget
    const Dock = () => Widget.Window({
        name: 'dock',
        anchor: ['bottom'],
        layer: 'top',
        margins: [0, 0, 20, 0],
        visible: true,
        child: Widget.Box({
            className: 'dock',
            css: `
                background: rgba(255, 255, 255, 0.8);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 20px;
                border: 1px solid rgba(0, 0, 0, 0.1);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                padding: 8px 16px;
            `,
            children: [
                ...dockItemWidgets,
                separator,
                trashWidget
            ]
        })
    });
    
    return Dock();
};