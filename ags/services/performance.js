// Performance Mode Service for HyprMac
// Controls CPU power profile: Balanced, Power Saving, Performance

import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

// Performance modes
const MODES = {
    POWER_SAVING: 'power-saver',
    BALANCED: 'balanced',
    PERFORMANCE: 'performance',
};

class PerformanceModeService extends Service {
    static {
        Service.register(
            this,
            {
                'changed': [],
            },
            {
                'mode': ['string', 'rw'],
                'available': ['boolean', 'r'],
            }
        );
    }

    #mode = MODES.BALANCED;
    #available = false;
    #backend = null; // 'powerprofiles', 'cpupower', or 'sysfs'

    get mode() {
        return this.#mode;
    }

    set mode(value) {
        if (!Object.values(MODES).includes(value)) {
            console.error(`Invalid mode: ${value}`);
            return;
        }
        
        if (this.#mode === value) return;
        
        this.#applyMode(value);
    }

    get available() {
        return this.#available;
    }

    // Get display name for mode
    static getDisplayName(mode) {
        switch (mode) {
            case MODES.POWER_SAVING: return 'Power Saving';
            case MODES.BALANCED: return 'Balanced';
            case MODES.PERFORMANCE: return 'Performance';
            default: return 'Unknown';
        }
    }

    // Get icon for mode
    static getIcon(mode) {
        switch (mode) {
            case MODES.POWER_SAVING: return 'battery-level-20-symbolic';
            case MODES.BALANCED: return 'battery-level-50-symbolic';
            case MODES.PERFORMANCE: return 'battery-level-100-charging-symbolic';
            default: return 'battery-symbolic';
        }
    }

    // Cycle to next mode
    cycleMode() {
        const modes = [MODES.POWER_SAVING, MODES.BALANCED, MODES.PERFORMANCE];
        const currentIndex = modes.indexOf(this.#mode);
        const nextIndex = (currentIndex + 1) % modes.length;
        this.mode = modes[nextIndex];
    }

    #applyMode(mode) {
        let command;
        
        switch (this.#backend) {
            case 'powerprofiles':
                command = `powerprofilesctl set ${mode}`;
                break;
            case 'cpupower':
                const governor = mode === MODES.PERFORMANCE ? 'performance' :
                    mode === MODES.POWER_SAVING ? 'powersave' : 'schedutil';
                command = `sudo cpupower frequency-set -g ${governor}`;
                break;
            case 'sysfs':
                const sysfsGovernor = mode === MODES.PERFORMANCE ? 'performance' :
                    mode === MODES.POWER_SAVING ? 'powersave' : 'schedutil';
                command = `echo ${sysfsGovernor} | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`;
                break;
            default:
                console.log(`Performance mode set to ${mode} (no backend available)`);
                this.#mode = mode;
                this.emit('changed');
                this.notify('mode');
                return;
        }

        Utils.execAsync(['bash', '-c', command])
            .then(() => {
                this.#mode = mode;
                this.emit('changed');
                this.notify('mode');
                console.log(`Performance mode set to ${mode}`);
            })
            .catch(err => {
                console.error(`Failed to set performance mode: ${err}`);
            });
    }

    #detectBackend() {
        // Try power-profiles-daemon first (modern standard)
        Utils.execAsync('which powerprofilesctl')
            .then(() => {
                this.#backend = 'powerprofiles';
                this.#available = true;
                this.#getCurrentMode();
                console.log('Using power-profiles-daemon backend');
            })
            .catch(() => {
                // Try cpupower
                Utils.execAsync('which cpupower')
                    .then(() => {
                        this.#backend = 'cpupower';
                        this.#available = true;
                        this.#getCurrentMode();
                        console.log('Using cpupower backend');
                    })
                    .catch(() => {
                        // Check sysfs as fallback
                        Utils.execAsync('cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')
                            .then(() => {
                                this.#backend = 'sysfs';
                                this.#available = true;
                                this.#getCurrentMode();
                                console.log('Using sysfs backend');
                            })
                            .catch(() => {
                                this.#available = false;
                                console.log('No performance mode backend available');
                            });
                    });
            });
    }

    #getCurrentMode() {
        if (this.#backend === 'powerprofiles') {
            Utils.execAsync('powerprofilesctl get')
                .then(out => {
                    const mode = out.trim();
                    if (Object.values(MODES).includes(mode)) {
                        this.#mode = mode;
                        this.emit('changed');
                        this.notify('mode');
                    }
                })
                .catch(() => {});
        } else if (this.#backend === 'cpupower' || this.#backend === 'sysfs') {
            Utils.execAsync('cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')
                .then(out => {
                    const governor = out.trim();
                    if (governor === 'performance') {
                        this.#mode = MODES.PERFORMANCE;
                    } else if (governor === 'powersave') {
                        this.#mode = MODES.POWER_SAVING;
                    } else {
                        this.#mode = MODES.BALANCED;
                    }
                    this.emit('changed');
                    this.notify('mode');
                })
                .catch(() => {});
        }
    }

    constructor() {
        super();
        this.#detectBackend();
    }
}

// Export modes enum
export const Modes = MODES;

// Singleton export
const service = new PerformanceModeService();
export default service;
