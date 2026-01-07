// macOS-style Control Center
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import Bluetooth from 'resource:///com/github/Aylur/ags/service/bluetooth.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

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
let dndEnabled = false;
const DNDToggle = () => Widget.Button({
    className: 'cc-toggle',
    onClicked: (self) => {
        dndEnabled = !dndEnabled;
        self.toggleClassName('active', dndEnabled);
        Utils.execAsync(`swaync-client ${dndEnabled ? '-d' : '-D'}`);
    },
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon: 'notifications-disabled-symbolic', size: 24 }),
            Widget.Label({ label: 'Focus', className: 'toggle-label' }),
        ],
    }),
});

// Night Shift Toggle
let nightShiftEnabled = false;
const NightShiftToggle = () => Widget.Button({
    className: 'cc-toggle',
    onClicked: (self) => {
        nightShiftEnabled = !nightShiftEnabled;
        self.toggleClassName('active', nightShiftEnabled);
        if (nightShiftEnabled) {
            Utils.execAsync('gammastep -O 4500');
        } else {
            Utils.execAsync('pkill gammastep');
        }
    },
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Icon({ icon: 'night-light-symbolic', size: 24 }),
            Widget.Label({ label: 'Night Shift', className: 'toggle-label' }),
        ],
    }),
});

// Quick Toggles Grid
const QuickToggles = () => Widget.Box({
    className: 'cc-toggles',
    homogeneous: true,
    children: [
        WifiToggle(),
        BluetoothToggle(),
        DNDToggle(),
        NightShiftToggle(),
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
            onChange: ({ value }) => {
                Utils.execAsync(`brightnessctl s ${Math.round(value * 100)}%`);
            },
            setup: self => {
                // Get initial brightness
                Utils.execAsync('brightnessctl g')
                    .then(out => {
                        Utils.execAsync('brightnessctl m').then(max => {
                            self.value = parseInt(out) / parseInt(max);
                        });
                    })
                    .catch(() => self.value = 1);
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
            MediaPlayer(),
        ],
    }),
});
