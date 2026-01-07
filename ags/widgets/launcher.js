// macOS-style Spotlight Launcher
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Applications from 'resource:///com/github/Aylur/ags/service/applications.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Theme from '../services/theme.js';
import WallpaperColors from '../services/wallpaper-colors.js';

// Results variable
const Results = Variable([]);

// App Item in results
const AppItem = (app) => Widget.Button({
    className: 'launcher-item',
    onClicked: () => {
        App.closeWindow('launcher');
        app.launch();
    },
    child: Widget.Box({
        children: [
            Widget.Icon({
                icon: app.icon_name || 'application-x-executable',
                size: 32,
            }),
            Widget.Box({
                vertical: true,
                vpack: 'center',
                children: [
                    Widget.Label({
                        className: 'launcher-item-name',
                        label: app.name,
                        xalign: 0,
                        truncate: 'end',
                    }),
                    Widget.Label({
                        className: 'launcher-item-desc',
                        label: app.description || '',
                        xalign: 0,
                        truncate: 'end',
                    }),
                ],
            }),
        ],
    }),
});

// Search Entry
const SearchEntry = (onSearch) => Widget.Entry({
    className: 'launcher-search',
    placeholder_text: 'Search...',
    hexpand: true,
    onAccept: ({ text }) => {
        const apps = Applications.query(text || '');
        if (apps[0]) {
            App.closeWindow('launcher');
            apps[0].launch();
        }
    },
    onChange: ({ text }) => onSearch(text),
    setup: self => {
        // Focus on show
        self.hook(App, (_, name, visible) => {
            if (name === 'launcher' && visible) {
                self.text = '';
                self.grab_focus();
            }
        }, 'window-toggled');
    },
});

// Results List
const ResultsList = () => Widget.Scrollable({
    className: 'launcher-results',
    hscroll: 'never',
    vscroll: 'automatic',
    child: Widget.Box({
        vertical: true,
        children: Results.bind().as(apps => apps.slice(0, 8).map(AppItem)),
    }),
});

// Main Launcher Window
export const Launcher = () => {
    const searchHandler = (text) => {
        Results.value = Applications.query(text || '');
    };
    
    // Initialize with all apps
    Results.value = Applications.list;
    
    return Widget.Window({
        name: 'launcher',
        anchor: ['top'],
        className: 'launcher-window',
        visible: false,
        keymode: 'exclusive',
        exclusivity: 'ignore',
        layer: 'overlay',
        setup: self => self.keybind('Escape', () => App.closeWindow('launcher')),
        child: Widget.Box({
            className: 'launcher',
            vertical: true,
            setup: self => {
                self.hook(Theme, () => {
                    self.toggleClassName('dark', Theme.isDark);
                    self.toggleClassName('light', !Theme.isDark);
                });
                self.hook(WallpaperColors, () => {
                    self.toggleClassName('dynamic-colors', WallpaperColors.dynamicEnabled);
                });
            },
            children: [
                Widget.Box({
                    className: 'launcher-header',
                    children: [
                        Widget.Icon({ icon: 'system-search-symbolic', size: 24 }),
                        SearchEntry(searchHandler),
                    ],
                }),
                ResultsList(),
            ],
        }),
    });
};
