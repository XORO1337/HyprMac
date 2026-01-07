// Brightness Service for HyprMac
// Provides reactive brightness state management

import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

class BrightnessService extends Service {
    static {
        Service.register(
            this,
            {
                'screen-changed': ['float'],
            },
            {
                'screen-value': ['float', 'rw'],
            }
        );
    }

    #screenValue = 0;
    #max = 0;

    get screen_value() {
        return this.#screenValue;
    }

    set screen_value(percent) {
        if (percent < 0) percent = 0;
        if (percent > 1) percent = 1;

        Utils.execAsync(`brightnessctl s ${Math.round(percent * 100)}% -q`)
            .then(() => {
                this.#screenValue = percent;
                this.emit('screen-changed', percent);
                this.notify('screen-value');
            })
            .catch(console.error);
    }

    constructor() {
        super();

        // Get initial brightness
        Utils.execAsync('brightnessctl m')
            .then(max => {
                this.#max = parseInt(max) || 1;
                return Utils.execAsync('brightnessctl g');
            })
            .then(current => {
                this.#screenValue = parseInt(current) / this.#max;
                this.emit('screen-changed', this.#screenValue);
            })
            .catch(() => {
                this.#screenValue = 1;
                this.#max = 1;
            });

        // Monitor for external brightness changes
        Utils.interval(5000, () => {
            Utils.execAsync('brightnessctl g')
                .then(current => {
                    const value = parseInt(current) / this.#max;
                    if (Math.abs(value - this.#screenValue) > 0.01) {
                        this.#screenValue = value;
                        this.emit('screen-changed', value);
                        this.notify('screen-value');
                    }
                })
                .catch(() => {});
        });
    }
}

// Singleton export
const service = new BrightnessService();
export default service;
