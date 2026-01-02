// Control Center Widget
// macOS-style control center with system controls

import { Widget, Service } from '../imports.js';
import { exec, execAsync } from '../utils.js';

const audio = await Service.import('audio');
const network = await Service.import('network');
const bluetooth = await Service.import('bluetooth');

export default () => {
    const ControlCenter = () => Widget.Window({
        name: 'control-center',
        anchor: ['top', 'right'],
        layer: 'top',
        margins: [40, 20, 0, 0],
        visible: false,
        keymode: 'exclusive',
        child: Widget.Box({
            className: 'control-center',
            vertical: true,
            css: `
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 16px;
                border: 1px solid rgba(0, 0, 0, 0.1);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                min-width: 320px;
                max-width: 320px;
            `,
            children: [
                // Header
                Widget.Box({
                    css: 'padding: 16px; border-bottom: 1px solid rgba(0, 0, 0, 0.1);',
                    children: [
                        Widget.Label({
                            label: 'Control Center',
                            css: 'font-size: 18px; font-weight: 600;'
                        })
                    ]
                }),
                
                // WiFi Section
                Widget.Box({
                    vertical: true,
                    css: 'padding: 16px; border-bottom: 1px solid rgba(0, 0, 0, 0.1);',
                    children: [
                        Widget.Box({
                            children: [
                                Widget.Icon({
                                    icon: 'network-wireless-symbolic',
                                    size: 24,
                                    css: 'margin-right: 12px;'
                                }),
                                Widget.Label({
                                    label: 'Wi-Fi',
                                    css: 'font-weight: 500;'
                                }),
                                Widget.Box({
                                    hexpand: true
                                }),
                                Widget.Switch({
                                    active: network.wifi.enabled,
                                    onChange: (self) => {
                                        if (self.active) {
                                            execAsync('nmcli radio wifi on');
                                        } else {
                                            execAsync('nmcli radio wifi off');
                                        }
                                    }
                                })
                            ]
                        }),
                        Widget.Box({
                            css: 'margin-top: 8px;',
                            children: [
                                Widget.Label({
                                    label: network.wifi.ssid || 'Not Connected',
                                    css: 'opacity: 0.7;'
                                })
                            ]
                        })
                    ]
                }),
                
                // Bluetooth Section
                Widget.Box({
                    vertical: true,
                    css: 'padding: 16px; border-bottom: 1px solid rgba(0, 0, 0, 0.1);',
                    children: [
                        Widget.Box({
                            children: [
                                Widget.Icon({
                                    icon: 'bluetooth-symbolic',
                                    size: 24,
                                    css: 'margin-right: 12px;'
                                }),
                                Widget.Label({
                                    label: 'Bluetooth',
                                    css: 'font-weight: 500;'
                                }),
                                Widget.Box({
                                    hexpand: true
                                }),
                                Widget.Switch({
                                    active: bluetooth.enabled,
                                    onChange: (self) => {
                                        if (self.active) {
                                            execAsync('bluetoothctl power on');
                                        } else {
                                            execAsync('bluetoothctl power off');
                                        }
                                    }
                                })
                            ]
                        }),
                        Widget.Box({
                            css: 'margin-top: 8px;',
                            children: [
                                Widget.Label({
                                    label: bluetooth.connected_devices.length + ' devices connected',
                                    css: 'opacity: 0.7;'
                                })
                            ]
                        })
                    ]
                }),
                
                // Volume Section
                Widget.Box({
                    vertical: true,
                    css: 'padding: 16px; border-bottom: 1px solid rgba(0, 0, 0, 0.1);',
                    children: [
                        Widget.Box({
                            children: [
                                Widget.Icon({
                                    icon: audio.speaker.is_muted ? 'audio-volume-muted-symbolic' : 
                                          audio.speaker.volume > 0.7 ? 'audio-volume-high-symbolic' :
                                          audio.speaker.volume > 0.3 ? 'audio-volume-medium-symbolic' :
                                          'audio-volume-low-symbolic',
                                    size: 24,
                                    css: 'margin-right: 12px;'
                                }),
                                Widget.Label({
                                    label: 'Volume',
                                    css: 'font-weight: 500;'
                                })
                            ]
                        }),
                        Widget.Slider({
                            value: audio.speaker.volume,
                            onChange: (self) => {
                                audio.speaker.volume = self.value;
                            },
                            css: 'margin-top: 12px;'
                        }),
                        Widget.Box({
                            css: 'margin-top: 8px;',
                            children: [
                                Widget.Label({
                                    label: Math.round(audio.speaker.volume * 100) + '%',
                                    css: 'opacity: 0.7;'
                                })
                            ]
                        })
                    ]
                }),
                
                // Brightness Section
                Widget.Box({
                    vertical: true,
                    css: 'padding: 16px; border-bottom: 1px solid rgba(0, 0, 0, 0.1);',
                    children: [
                        Widget.Box({
                            children: [
                                Widget.Icon({
                                    icon: 'display-brightness-symbolic',
                                    size: 24,
                                    css: 'margin-right: 12px;'
                                }),
                                Widget.Label({
                                    label: 'Display',
                                    css: 'font-weight: 500;'
                                })
                            ]
                        }),
                        Widget.Slider({
                            value: 0.5, // Default brightness
                            onChange: (self) => {
                                const brightness = Math.round(self.value * 100);
                                execAsync(`brightnessctl set ${brightness}%`);
                            },
                            css: 'margin-top: 12px;'
                        }),
                        Widget.Box({
                            css: 'margin-top: 8px;',
                            children: [
                                Widget.Label({
                                    label: '50%',
                                    css: 'opacity: 0.7;'
                                })
                            ]
                        })
                    ]
                }),
                
                // Media Controls
                Widget.Box({
                    vertical: true,
                    css: 'padding: 16px; border-bottom: 1px solid rgba(0, 0, 0, 0.1);',
                    children: [
                        Widget.Label({
                            label: 'Now Playing',
                            css: 'font-weight: 500; margin-bottom: 12px;'
                        }),
                        Widget.Box({
                            spacing: 12,
                            homogeneous: true,
                            children: [
                                Widget.Button({
                                    child: Widget.Icon({ icon: 'media-skip-backward-symbolic', size: 20 }),
                                    onClicked: () => execAsync('playerctl previous'),
                                    css: 'padding: 8px;'
                                }),
                                Widget.Button({
                                    child: Widget.Icon({ icon: 'media-playback-start-symbolic', size: 24 }),
                                    onClicked: () => execAsync('playerctl play-pause'),
                                    css: 'padding: 8px;'
                                }),
                                Widget.Button({
                                    child: Widget.Icon({ icon: 'media-skip-forward-symbolic', size: 20 }),
                                    onClicked: () => execAsync('playerctl next'),
                                    css: 'padding: 8px;'
                                })
                            ]
                        })
                    ]
                }),
                
                // Quick Actions
                Widget.Box({
                    vertical: true,
                    css: 'padding: 16px;',
                    children: [
                        Widget.Label({
                            label: 'Quick Actions',
                            css: 'font-weight: 500; margin-bottom: 12px;'
                        }),
                        Widget.Box({
                            spacing: 8,
                            children: [
                                Widget.Button({
                                    child: Widget.Label('Lock Screen'),
                                    onClicked: () => execAsync('hyprlock'),
                                    css: 'padding: 8px 16px;'
                                }),
                                Widget.Button({
                                    child: Widget.Label('Settings'),
                                    onClicked: () => execAsync('gnome-control-center'),
                                    css: 'padding: 8px 16px;'
                                }),
                                Widget.Button({
                                    child: Widget.Label('Power'),
                                    onClicked: () => execAsync('wofi --show power-menu'),
                                    css: 'padding: 8px 16px;'
                                })
                            ]
                        })
                    ]
                })
            ]
        })
    });
    
    // Toggle control center
    globalThis.showControlCenter = () => {
        const controlCenter = App.getWindow('control-center');
        if (controlCenter.visible) {
            App.closeWindow('control-center');
        } else {
            App.openWindow('control-center');
        }
    };
    
    return ControlCenter();
};