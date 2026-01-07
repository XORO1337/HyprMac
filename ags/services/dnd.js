// Do Not Disturb Service for HyprMac
// Integrates with swaync for notification control

import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

class DNDService extends Service {
    static {
        Service.register(
            this,
            {
                'changed': [],
            },
            {
                'enabled': ['boolean', 'rw'],
            }
        );
    }

    #enabled = false;

    get enabled() {
        return this.#enabled;
    }

    set enabled(value) {
        if (this.#enabled === value) return;
        
        this.#enabled = value;
        
        // Use swaync-client to toggle DND
        const flag = value ? '-d' : '-D';
        Utils.execAsync(`swaync-client ${flag}`)
            .catch(console.error);
        
        this.emit('changed');
        this.notify('enabled');
    }

    toggle() {
        this.enabled = !this.#enabled;
    }

    constructor() {
        super();
        
        // Check current DND state from swaync
        Utils.execAsync('swaync-client -D')
            .then(out => {
                this.#enabled = out.includes('true');
            })
            .catch(() => {
                this.#enabled = false;
            });
        
        // Subscribe to swaync changes
        Utils.subprocess(
            ['swaync-client', '-s'],
            out => {
                try {
                    const state = JSON.parse(out);
                    if (state.dnd !== undefined && state.dnd !== this.#enabled) {
                        this.#enabled = state.dnd;
                        this.emit('changed');
                        this.notify('enabled');
                    }
                } catch (e) {
                    // Ignore parse errors
                }
            }
        );
    }
}

// Singleton export
const service = new DNDService();
export default service;
