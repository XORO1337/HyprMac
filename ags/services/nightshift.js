// Night Shift Service for HyprMac
// Controls screen color temperature with gammastep

import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

class NightShiftService extends Service {
    static {
        Service.register(
            this,
            {
                'changed': [],
            },
            {
                'enabled': ['boolean', 'rw'],
                'temperature': ['int', 'rw'],
            }
        );
    }

    #enabled = false;
    #temperature = 4500; // Default warm temperature

    get enabled() {
        return this.#enabled;
    }

    set enabled(value) {
        if (this.#enabled === value) return;
        
        this.#enabled = value;
        
        if (value) {
            Utils.execAsync(`gammastep -O ${this.#temperature}`)
                .catch(console.error);
        } else {
            Utils.execAsync('pkill gammastep')
                .catch(() => {}); // May not be running
        }
        
        this.emit('changed');
        this.notify('enabled');
    }

    get temperature() {
        return this.#temperature;
    }

    set temperature(value) {
        if (value < 1000) value = 1000;
        if (value > 10000) value = 10000;
        
        this.#temperature = value;
        
        if (this.#enabled) {
            // Restart with new temperature
            Utils.execAsync('pkill gammastep')
                .then(() => Utils.execAsync(`gammastep -O ${value}`))
                .catch(console.error);
        }
        
        this.emit('changed');
        this.notify('temperature');
    }

    toggle() {
        this.enabled = !this.#enabled;
    }

    constructor() {
        super();
        
        // Check if gammastep is already running
        Utils.execAsync('pgrep gammastep')
            .then(() => {
                this.#enabled = true;
                this.notify('enabled');
            })
            .catch(() => {
                this.#enabled = false;
            });
    }
}

// Singleton export
const service = new NightShiftService();
export default service;
