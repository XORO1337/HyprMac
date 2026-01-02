// Apple Menu Widget
// macOS-style Apple menu dropdown

import { Widget } from '../imports.js';
import { execAsync } from '../utils.js';

export default () => {
    const AppleMenu = () => Widget.Window({
        name: 'apple-menu',
        anchor: ['top', 'left'],
        layer: 'top',
        visible: false,
        keymode: 'exclusive',
        child: Widget.Box({
            className: 'apple-menu',
            vertical: true,
            children: [
                // About This Mac
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('About This Mac'),
                    onClicked: () => {
                        execAsync('neofetch');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // Separator
                Widget.Separator({ className: 'apple-menu-separator' }),
                
                // System Preferences
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('System Preferences...'),
                    onClicked: () => {
                        execAsync('gnome-control-center');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // App Store
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('App Store'),
                    onClicked: () => {
                        execAsync('firefox https://archlinux.org/packages/');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // Separator
                Widget.Separator({ className: 'apple-menu-separator' }),
                
                // Recent Items
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('Recent Items'),
                    onClicked: () => {
                        execAsync('nautilus recent:///');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // Force Quit
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('Force Quit'),
                    onClicked: () => {
                        execAsync('hyprctl kill');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // Separator
                Widget.Separator({ className: 'apple-menu-separator' }),
                
                // Sleep
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('Sleep'),
                    onClicked: () => {
                        execAsync('systemctl suspend');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // Restart
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('Restart...'),
                    onClicked: () => {
                        execAsync('systemctl reboot');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // Shut Down
                Widget.Button({
                    className: 'apple-menu-item danger',
                    child: Widget.Label('Shut Down...'),
                    onClicked: () => {
                        execAsync('systemctl poweroff');
                        App.closeWindow('apple-menu');
                    },
                }),
                
                // Separator
                Widget.Separator({ className: 'apple-menu-separator' }),
                
                // Log Out
                Widget.Button({
                    className: 'apple-menu-item',
                    child: Widget.Label('Log Out ' + Utils.USER + '...'),
                    onClicked: () => {
                        execAsync('hyprctl dispatch exit');
                        App.closeWindow('apple-menu');
                    },
                }),
            ],
        }),
    });
    
    // Toggle apple menu
    globalThis.showAppleMenu = () => {
        const appleMenu = App.getWindow('apple-menu');
        if (appleMenu.visible) {
            App.closeWindow('apple-menu');
        } else {
            App.openWindow('apple-menu');
        }
    };
    
    return AppleMenu();
};