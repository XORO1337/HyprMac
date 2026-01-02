// Spotlight Widget
// macOS-style system-wide search

import { Widget } from '../imports.js';
import { exec, execAsync } from '../utils.js';
import Applications from 'resource:///com/github/Aylur/ags/service/applications.js';

export default () => {
    let applications = [];
    let searchResults = [];
    
    // Get all applications
    const updateApplications = () => {
        applications = Applications.query('');
    };
    
    // Search function
    const search = (query) => {
        if (!query || query.length === 0) {
            return [];
        }
        
        // Search applications
        const appResults = Applications.query(query.toLowerCase());
        
        // Add additional search results
        const results = [
            ...appResults.map(app => ({
                type: 'app',
                name: app.name,
                description: app.description || '',
                icon: app.icon_name || 'application-default',
                action: () => execAsync(app.executable)
            })),
            
            // System actions
            {
                type: 'action',
                name: 'Lock Screen',
                description: 'Lock the screen',
                icon: 'system-lock-screen',
                action: () => execAsync('hyprlock')
            },
            {
                type: 'action',
                name: 'Sleep',
                description: 'Put computer to sleep',
                icon: 'system-suspend',
                action: () => execAsync('systemctl suspend')
            },
            {
                type: 'action',
                name: 'Restart',
                description: 'Restart the computer',
                icon: 'system-restart',
                action: () => execAsync('systemctl reboot')
            },
            {
                type: 'action',
                name: 'Shut Down',
                description: 'Shut down the computer',
                icon: 'system-shutdown',
                action: () => execAsync('systemctl poweroff')
            },
            
            // Calculator functionality
            {
                type: 'calculator',
                name: `Calculate: ${query}`,
                description: 'Perform calculation',
                icon: 'accessories-calculator',
                action: () => {
                    try {
                        const result = eval(query.replace(/[^0-9+\-*/.()]/g, ''));
                        execAsync(`echo ${result} | wl-copy`);
                    } catch (e) {
                        // Invalid calculation
                    }
                }
            },
            
            // Web search
            {
                type: 'web',
                name: `Search web for "${query}"`,
                description: 'Search the web',
                icon: 'web-browser',
                action: () => execAsync(`firefox "https://duckduckgo.com/?q=${encodeURIComponent(query)}"`)
            },
            
            // File search
            {
                type: 'file',
                name: `Find files matching "${query}"`,
                description: 'Search for files',
                icon: 'system-file-manager',
                action: () => execAsync(`nautilus search://${query}`)
            }
        ];
        
        return results;
    };
    
    // Spotlight search entry
    const searchEntry = Widget.Entry({
        className: 'spotlight-entry',
        placeholder_text: 'Search',
        hexpand: true,
        vexpand: false,
        css: `
            font-size: 18px;
            padding: 12px 16px;
            border: none;
            background: transparent;
            color: #1d1d1f;
            outline: none;
            box-shadow: none;
        `,
        on_accept: (self) => {
            const text = self.text;
            if (searchResults.length > 0) {
                searchResults[0].action();
                App.closeWindow('spotlight');
            }
        },
        on_change: (self) => {
            const query = self.text;
            searchResults = search(query);
            resultsList.children = searchResults.map((result, index) => 
                Widget.Button({
                    className: `spotlight-result ${index === 0 ? 'selected' : ''}`,
                    child: Widget.Box({
                        children: [
                            Widget.Icon({
                                icon: result.icon,
                                size: 24,
                                css: 'margin-right: 12px;'
                            }),
                            Widget.Box({
                                vertical: true,
                                children: [
                                    Widget.Label({
                                        label: result.name,
                                        css: 'font-weight: 600; font-size: 14px;'
                                    }),
                                    Widget.Label({
                                        label: result.description,
                                        css: 'font-size: 12px; opacity: 0.7;'
                                    })
                                ]
                            })
                        ]
                    }),
                    onClicked: () => {
                        result.action();
                        App.closeWindow('spotlight');
                    }
                })
            );
        }
    });
    
    // Search results list
    const resultsList = Widget.Box({
        className: 'spotlight-results',
        vertical: true,
        spacing: 4,
        css: 'padding: 8px 0; max-height: 400px;'
    });
    
    // Main spotlight window
    const Spotlight = () => Widget.Window({
        name: 'spotlight',
        anchor: ['top'],
        layer: 'overlay',
        visible: false,
        keymode: 'exclusive',
        child: Widget.Box({
            className: 'spotlight',
            vertical: true,
            css: `
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 12px;
                border: 1px solid rgba(0, 0, 0, 0.1);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                margin: 24px;
                min-width: 680px;
                max-width: 680px;
            `,
            children: [
                // Search entry
                searchEntry,
                
                // Separator
                Widget.Separator({
                    className: 'spotlight-separator',
                    css: 'margin: 0 16px; background: rgba(0, 0, 0, 0.1);'
                }),
                
                // Results list
                resultsList
            ],
        }),
    });
    
    // Toggle spotlight
    globalThis.showSpotlight = () => {
        const spotlight = App.getWindow('spotlight');
        if (spotlight.visible) {
            App.closeWindow('spotlight');
        } else {
            App.openWindow('spotlight');
            searchEntry.text = '';
            searchEntry.grab_focus();
            updateApplications();
        }
    };
    
    // Key handling
    App.addWindow(Spotlight());
    
    return Spotlight();
};