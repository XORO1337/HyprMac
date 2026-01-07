// macOS-style Notification Popups
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

// Individual Notification
const Notification = (notification) => {
    const icon = Widget.Box({
        className: 'notification-icon',
        vpack: 'start',
        child: notification.image ? Widget.Box({
            css: `
                background-image: url('${notification.image}');
                background-size: cover;
                background-position: center;
                min-width: 48px;
                min-height: 48px;
                border-radius: 8px;
            `,
        }) : Widget.Icon({
            icon: notification.app_icon || 'dialog-information-symbolic',
            size: 48,
        }),
    });

    const title = Widget.Label({
        className: 'notification-title',
        label: notification.summary,
        xalign: 0,
        truncate: 'end',
        maxWidthChars: 30,
    });

    const body = Widget.Label({
        className: 'notification-body',
        label: notification.body,
        xalign: 0,
        wrap: true,
        wrapMode: 'WORD_CHAR',
        maxWidthChars: 35,
    });

    const actions = Widget.Box({
        className: 'notification-actions',
        children: notification.actions.map(action => Widget.Button({
            className: 'notification-action',
            child: Widget.Label({ label: action.label }),
            onClicked: () => notification.invoke(action.id),
        })),
    });

    return Widget.EventBox({
        onPrimaryClick: () => notification.dismiss(),
        child: Widget.Box({
            className: `notification ${notification.urgency}`,
            children: [
                icon,
                Widget.Box({
                    vertical: true,
                    hexpand: true,
                    children: [
                        Widget.Box({
                            children: [
                                title,
                                Widget.Label({
                                    className: 'notification-app',
                                    label: notification.app_name,
                                    hexpand: true,
                                    xalign: 1,
                                }),
                                Widget.Button({
                                    className: 'notification-close',
                                    child: Widget.Label({ label: '✕' }),
                                    onClicked: () => notification.close(),
                                }),
                            ],
                        }),
                        body,
                        actions,
                    ],
                }),
            ],
        }),
    });
};

// Notification Popup List
const NotificationList = () => Widget.Box({
    vertical: true,
    className: 'notification-list',
    children: Notifications.bind('popups').as(popups => 
        popups.map(Notification)
    ),
});

// Main Notification Popup Window
export const NotificationPopups = () => Widget.Window({
    name: 'notifications',
    anchor: ['top', 'right'],
    className: 'notification-popups',
    child: NotificationList(),
});
