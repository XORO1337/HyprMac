// macOS-style Top Menu Bar
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import Bluetooth from 'resource:///com/github/Aylur/ags/service/bluetooth.js';
import SystemTray from 'resource:///com/github/Aylur/ags/service/systemtray.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import GLib from 'gi://GLib';

// Apple Logo
const AppleMenu = () => Widget.Button({
    className: 'apple-menu',
    child: Widget.Label({ label: '' }),
    onClicked: () => App.toggleWindow('launcher'),
});

// Active App Name (like macOS shows focused app)
const ActiveApp = () => Widget.Label({
    className: 'active-app',
    setup: self => self.hook(Hyprland.active.client, () => {
        const client = Hyprland.active.client;
        self.label = client.class || 'Desktop';
    }),
});

// Workspace Indicators (like macOS Spaces in menu bar)
const Workspaces = () => Widget.Box({
    className: 'workspaces',
    children: Hyprland.bind('workspaces').as(ws => 
        ws.sort((a, b) => a.id - b.id).map(workspace => Widget.Button({
            className: Hyprland.active.workspace.bind('id').as(id => 
                id === workspace.id ? 'workspace-btn active' : 'workspace-btn'),
            child: Widget.Label({ label: `${workspace.id}` }),
            onClicked: () => Hyprland.messageAsync(`dispatch workspace ${workspace.id}`),
        }))
    ),
});

// Clock with date (like macOS)
const Clock = () => Widget.Label({
    className: 'clock',
    setup: self => {
        const update = () => {
            const now = GLib.DateTime.new_now_local();
            self.label = now.format('%a %b %d  %I:%M %p');
            return true;
        };
        update();
        Utils.interval(1000, update);
    },
});

// Battery indicator
const BatteryIndicator = () => Widget.Box({
    className: 'battery',
    visible: Battery.bind('available'),
    children: [
        Widget.Icon({
            icon: Battery.bind('icon_name'),
        }),
        Widget.Label({
            label: Battery.bind('percent').as(p => `${p}%`),
        }),
    ],
});

// Volume indicator
const VolumeIndicator = () => Widget.Button({
    className: 'volume',
    onClicked: () => App.toggleWindow('control-center'),
    onScrollUp: () => Audio.speaker && (Audio.speaker.volume += 0.05),
    onScrollDown: () => Audio.speaker && (Audio.speaker.volume -= 0.05),
    child: Widget.Icon({
        setup: self => self.hook(Audio, () => {
            if (!Audio.speaker) return;
            const vol = Audio.speaker.volume * 100;
            const icon = Audio.speaker.is_muted ? 'audio-volume-muted-symbolic' :
                vol > 66 ? 'audio-volume-high-symbolic' :
                vol > 33 ? 'audio-volume-medium-symbolic' :
                vol > 0 ? 'audio-volume-low-symbolic' : 'audio-volume-muted-symbolic';
            self.icon = icon;
        }, 'speaker-changed'),
    }),
});

// WiFi indicator
const WifiIndicator = () => Widget.Icon({
    className: 'wifi',
    setup: self => self.hook(Network, () => {
        if (Network.wifi) {
            self.icon = Network.wifi.icon_name;
            self.tooltip_text = Network.wifi.ssid || 'Not connected';
        }
    }),
});

// Bluetooth indicator
const BluetoothIndicator = () => Widget.Icon({
    className: 'bluetooth',
    visible: Bluetooth.bind('enabled'),
    icon: 'bluetooth-active-symbolic',
    tooltip_text: Bluetooth.bind('connected_devices').as(d => 
        d.length > 0 ? d.map(d => d.name).join(', ') : 'No devices'),
});

// Control Center button
const ControlCenterButton = () => Widget.Button({
    className: 'control-center-btn',
    child: Widget.Icon({ icon: 'emblem-system-symbolic' }),
    onClicked: () => App.toggleWindow('control-center'),
});

// System Tray
const SysTray = () => Widget.Box({
    className: 'systray',
    children: SystemTray.bind('items').as(items =>
        items.map(item => Widget.Button({
            child: Widget.Icon({ icon: item.bind('icon') }),
            onPrimaryClick: (_, event) => item.activate(event),
            onSecondaryClick: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind('tooltip_markup'),
        }))
    ),
});

// Left side of bar
const Left = () => Widget.Box({
    className: 'bar-left',
    hpack: 'start',
    children: [
        AppleMenu(),
        ActiveApp(),
    ],
});

// Center of bar
const Center = () => Widget.Box({
    className: 'bar-center',
    hpack: 'center',
    children: [
        Workspaces(),
    ],
});

// Right side of bar
const Right = () => Widget.Box({
    className: 'bar-right',
    hpack: 'end',
    spacing: 8,
    children: [
        SysTray(),
        BluetoothIndicator(),
        WifiIndicator(),
        VolumeIndicator(),
        BatteryIndicator(),
        Clock(),
        ControlCenterButton(),
    ],
});

// Main Bar
export const Bar = (monitor = 0) => Widget.Window({
    name: `bar-${monitor}`,
    monitor,
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    className: 'bar',
    child: Widget.CenterBox({
        className: 'bar-container',
        startWidget: Left(),
        centerWidget: Center(),
        endWidget: Right(),
    }),
});
