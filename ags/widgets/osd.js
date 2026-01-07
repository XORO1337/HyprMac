// OSD (On Screen Display) for Volume/Brightness
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

const DELAY = 1500;
let count = 0;

// Progress bar for OSD
const Progress = () => Widget.Box({
    className: 'osd-progress',
    child: Widget.LevelBar({
        widthRequest: 200,
        barMode: 'continuous',
        value: 0,
    }),
});

// Icon for OSD
const OSDIcon = () => Widget.Icon({
    className: 'osd-icon',
    size: 48,
});

// OSD Container
const OSDContent = () => Widget.Box({
    className: 'osd',
    vertical: true,
    children: [
        OSDIcon(),
        Progress(),
    ],
});

// Show OSD
const show = (icon, value, window) => {
    const iconWidget = window.child.children[0];
    const progressWidget = window.child.children[1].child;
    
    iconWidget.icon = icon;
    progressWidget.value = value;
    
    window.visible = true;
    count++;
    
    Utils.timeout(DELAY, () => {
        count--;
        if (count === 0) {
            window.visible = false;
        }
    });
};

// Main OSD Window
export const OSD = () => {
    const window = Widget.Window({
        name: 'osd',
        anchor: ['bottom'],
        className: 'osd-window',
        visible: false,
        layer: 'overlay',
        child: OSDContent(),
    });
    
    // Hook into Audio for volume changes
    window.hook(Audio, () => {
        if (!Audio.speaker) return;
        
        const vol = Audio.speaker.volume;
        const icon = Audio.speaker.is_muted ? 'audio-volume-muted-symbolic' :
            vol > 0.66 ? 'audio-volume-high-symbolic' :
            vol > 0.33 ? 'audio-volume-medium-symbolic' :
            vol > 0 ? 'audio-volume-low-symbolic' : 'audio-volume-muted-symbolic';
        
        show(icon, vol, window);
    }, 'speaker-changed');
    
    return window;
};
