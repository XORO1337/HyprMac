// macOS-style Control Center
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import Bluetooth from 'resource:///com/github/Aylur/ags/service/bluetooth.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

// Custom services
import Brightness from '../services/brightness.js';
import NightShift from '../services/nightshift.js';
import DND from '../services/dnd.js';
import PerformanceMode, { Modes as PerfModes } from '../services/performance.js';
import Theme from '../services/theme.js';
import WallpaperColors from '../services/wallpaper-colors.js';

// Header
const Header = () => Widget.Box({
    className: 'cc-header',
    children: [
        Widget.Label({
            className: 'cc-title',
            label: 'Control Center',
            hexpand: true,
            xalign: 0,
        }),
        Widget.Button({
            className: 'cc-close',
            child: Widget.Label({ label: '✕' }),
            onClicked: () => App.closeWindow('control-center'),
        }),
    ],
});

// Toggle Button Widget
const ToggleButton = (icon, label, isActive, onToggle) => Widget.Button({
    className: 'cc-toggle',
    setup: self => {
        if (typeof isActive === 'function') {
            self.toggleClassName('active', isActive());
        }
    },
    onClicked: (self) => {
        onToggle();
        self.toggleClassName('active');
    },
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon, size: 24 }),
            Widget.Label({ label, className: 'toggle-label' }),
        ],
    }),
});

// WiFi Toggle
const WifiToggle = () => Widget.Button({
    className: 'cc-toggle',
    setup: self => self.hook(Network, () => {
        if (Network.wifi) {
            self.toggleClassName('active', Network.wifi.enabled);
        }
    }),
    onClicked: () => {
        if (Network.wifi) {
            Network.wifi.enabled = !Network.wifi.enabled;
        }
    },
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({
                icon: Network.wifi?.bind('icon_name') || 'network-wireless-symbolic',
                size: 24,
            }),
            Widget.Label({
                label: 'Wi-Fi',
                className: 'toggle-label',
            }),
        ],
    }),
});

// Bluetooth Toggle
const BluetoothToggle = () => Widget.Button({
    className: 'cc-toggle',
    setup: self => self.hook(Bluetooth, () => {
        self.toggleClassName('active', Bluetooth.enabled);
    }),
    onClicked: () => {
        Bluetooth.enabled = !Bluetooth.enabled;
    },
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon: 'bluetooth-active-symbolic', size: 24 }),
            Widget.Label({ label: 'Bluetooth', className: 'toggle-label' }),
        ],
    }),
});

// Do Not Disturb Toggle
const DNDToggle = () => Widget.Button({
    className: 'cc-toggle',
    setup: self => self.hook(DND, () => {
        self.toggleClassName('active', DND.enabled);
    }),
    onClicked: () => DND.toggle(),
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon: 'notifications-disabled-symbolic', size: 24 }),
            Widget.Label({ label: 'Focus', className: 'toggle-label' }),
        ],
    }),
});

// Night Shift Toggle
const NightShiftToggle = () => Widget.Button({
    className: 'cc-toggle',
    setup: self => self.hook(NightShift, () => {
        self.toggleClassName('active', NightShift.enabled);
    }),
    onClicked: () => NightShift.toggle(),
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon: 'night-light-symbolic', size: 24 }),
            Widget.Label({ label: 'Night Shift', className: 'toggle-label' }),
        ],
    }),
});

// Theme Toggle (Dark/Light Mode)
const ThemeToggle = () => Widget.Button({
    className: 'cc-toggle cc-theme-toggle',
    setup: self => self.hook(Theme, () => {
        self.toggleClassName('active', Theme.isDark);
        self.toggleClassName('light-mode', !Theme.isDark);
    }),
    onClicked: () => Theme.toggle(),
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({
                setup: self => self.hook(Theme, () => {
                    self.icon = Theme.isDark ? 'weather-clear-night-symbolic' : 'weather-clear-symbolic';
                }),
                size: 24,
            }),
            Widget.Label({
                className: 'toggle-label',
                setup: self => self.hook(Theme, () => {
                    self.label = Theme.isDark ? 'Dark' : 'Light';
                }),
            }),
        ],
    }),
});

// Dynamic Colors Toggle (Wallpaper-based colors)
const DynamicColorsToggle = () => Widget.Button({
    className: 'cc-toggle cc-dynamic-toggle',
    setup: self => self.hook(WallpaperColors, () => {
        self.toggleClassName('active', WallpaperColors.dynamicEnabled);
    }),
    onClicked: () => WallpaperColors.toggleDynamic(),
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon: 'preferences-color-symbolic', size: 24 }),
            Widget.Label({ label: 'Colors', className: 'toggle-label' }),
        ],
    }),
});

// Wallpaper Picker Button
const WallpaperButton = () => Widget.Button({
    className: 'cc-toggle cc-wallpaper-toggle',
    onClicked: () => {
        App.closeWindow('control-center');
        App.openWindow('wallpaper-picker');
    },
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon: 'preferences-desktop-wallpaper-symbolic', size: 24 }),
            Widget.Label({ label: 'Wallpaper', className: 'toggle-label' }),
        ],
    }),
});

// Performance Mode Selector
const PerformanceModeSelector = () => Widget.Box({
    className: 'cc-performance',
    vertical: true,
    setup: self => self.hook(PerformanceMode, () => {
        self.visible = PerformanceMode.available;
    }),
    children: [
        Widget.Label({
            label: 'Performance',
            xalign: 0,
            className: 'cc-section-label',
        }),
        Widget.Box({
            className: 'cc-performance-modes',
            homogeneous: true,
            children: [
                // Power Saving
                Widget.Button({
                    className: 'cc-perf-btn',
                    setup: self => self.hook(PerformanceMode, () => {
                        self.toggleClassName('active', PerformanceMode.mode === PerfModes.POWER_SAVING);
                    }),
                    onClicked: () => PerformanceMode.mode = PerfModes.POWER_SAVING,
                    child: Widget.Box({
                        vertical: true,
                        children: [
                            Widget.Icon({ icon: 'battery-level-20-symbolic', size: 20 }),
                            Widget.Label({ label: 'Low', className: 'perf-label' }),
                        ],
                    }),
                }),
                // Balanced
                Widget.Button({
                    className: 'cc-perf-btn',
                    setup: self => self.hook(PerformanceMode, () => {
                        self.toggleClassName('active', PerformanceMode.mode === PerfModes.BALANCED);
                    }),
                    onClicked: () => PerformanceMode.mode = PerfModes.BALANCED,
                    child: Widget.Box({
                        vertical: true,
                        children: [
                            Widget.Icon({ icon: 'battery-level-50-symbolic', size: 20 }),
                            Widget.Label({ label: 'Auto', className: 'perf-label' }),
                        ],
                    }),
                }),
                // Performance
                Widget.Button({
                    className: 'cc-perf-btn',
                    setup: self => self.hook(PerformanceMode, () => {
                        self.toggleClassName('active', PerformanceMode.mode === PerfModes.PERFORMANCE);
                    }),
                    onClicked: () => PerformanceMode.mode = PerfModes.PERFORMANCE,
                    child: Widget.Box({
                        vertical: true,
                        children: [
                            Widget.Icon({ icon: 'battery-level-100-charging-symbolic', size: 20 }),
                            Widget.Label({ label: 'High', className: 'perf-label' }),
                        ],
                    }),
                }),
            ],
        }),
    ],
});

// Quick Toggles Grid
const QuickToggles = () => Widget.Box({
    className: 'cc-toggles-container',
    vertical: true,
    children: [
        // First row
        Widget.Box({
            className: 'cc-toggles',
            homogeneous: true,
            children: [
                WifiToggle(),
                BluetoothToggle(),
                DNDToggle(),
                NightShiftToggle(),
            ],
        }),
        // Second row - Theme and Wallpaper controls
        Widget.Box({
            className: 'cc-toggles cc-toggles-row2',
            homogeneous: true,
            children: [
                ThemeToggle(),
                DynamicColorsToggle(),
                WallpaperButton(),
            ],
        }),
    ],
});

// Brightness Slider
const BrightnessSlider = () => Widget.Box({
    className: 'cc-slider-box',
    children: [
        Widget.Icon({ icon: 'display-brightness-symbolic', size: 20 }),
        Widget.Slider({
            className: 'cc-slider',
            hexpand: true,
            drawValue: false,
            value: Brightness.bind('screen-value'),
            onChange: ({ value }) => {
                Brightness.screen_value = value;
            },
        }),
    ],
});

// Volume Slider
const VolumeSlider = () => Widget.Box({
    className: 'cc-slider-box',
    children: [
        Widget.Button({
            child: Widget.Icon({
                setup: self => self.hook(Audio, () => {
                    if (!Audio.speaker) return;
                    const icon = Audio.speaker.is_muted ? 'audio-volume-muted-symbolic' : 'audio-volume-high-symbolic';
                    self.icon = icon;
                }, 'speaker-changed'),
                size: 20,
            }),
            onClicked: () => {
                if (Audio.speaker) {
                    Audio.speaker.is_muted = !Audio.speaker.is_muted;
                }
            },
        }),
        Widget.Slider({
            className: 'cc-slider',
            hexpand: true,
            drawValue: false,
            setup: self => self.hook(Audio, () => {
                if (Audio.speaker) {
                    self.value = Audio.speaker.volume;
                }
            }, 'speaker-changed'),
            onChange: ({ value }) => {
                if (Audio.speaker) {
                    Audio.speaker.volume = value;
                }
            },
        }),
    ],
});

// Media Player (Now Playing)
const MediaPlayer = () => Widget.Box({
    className: 'cc-media',
    vertical: true,
    setup: self => self.hook(Mpris, () => {
        const player = Mpris.players[0];
        self.visible = !!player;
    }),
    children: [
        Widget.Box({
            className: 'media-info',
            children: [
                Widget.Box({
                    className: 'media-cover',
                    css: Mpris.bind('players').as(players => {
                        const player = players[0];
                        if (player?.cover_path) {
                            return `background-image: url('${player.cover_path}');`;
                        }
                        return '';
                    }),
                }),
                Widget.Box({
                    vertical: true,
                    vpack: 'center',
                    hexpand: true,
                    children: [
                        Widget.Label({
                            className: 'media-title',
                            xalign: 0,
                            truncate: 'end',
                            maxWidthChars: 20,
                            label: Mpris.bind('players').as(p => p[0]?.track_title || 'Not Playing'),
                        }),
                        Widget.Label({
                            className: 'media-artist',
                            xalign: 0,
                            truncate: 'end',
                            maxWidthChars: 20,
                            label: Mpris.bind('players').as(p => p[0]?.track_artists?.join(', ') || ''),
                        }),
                    ],
                }),
            ],
        }),
        Widget.Box({
            className: 'media-controls',
            hpack: 'center',
            children: [
                Widget.Button({
                    child: Widget.Icon({ icon: 'media-skip-backward-symbolic', size: 20 }),
                    onClicked: () => Mpris.players[0]?.previous(),
                }),
                Widget.Button({
                    child: Widget.Icon({
                        icon: Mpris.bind('players').as(p => 
                            p[0]?.play_back_status === 'Playing' ? 'media-playback-pause-symbolic' : 'media-playback-start-symbolic'
                        ),
                        size: 24,
                    }),
                    onClicked: () => Mpris.players[0]?.playPause(),
                }),
                Widget.Button({
                    child: Widget.Icon({ icon: 'media-skip-forward-symbolic', size: 20 }),
                    onClicked: () => Mpris.players[0]?.next(),
                }),
            ],
        }),
    ],
});

// Main Control Center Window
export const ControlCenter = () => Widget.Window({
    name: 'control-center',
    anchor: ['top', 'right'],
    className: 'control-center-window',
    visible: false,
    keymode: 'on-demand',
    child: Widget.Box({
        className: 'control-center',
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
            Header(),
            QuickToggles(),
            Widget.Box({
                className: 'cc-sliders',
                vertical: true,
                children: [
                    Widget.Label({ label: 'Display', xalign: 0, className: 'cc-section-label' }),
                    BrightnessSlider(),
                    Widget.Label({ label: 'Sound', xalign: 0, className: 'cc-section-label' }),
                    VolumeSlider(),
                ],
            }),
            PerformanceModeSelector(),
            MediaPlayer(),
        ],
    }),
});
