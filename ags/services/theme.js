// Theme Service for HyprMac
// Switches between Dark and Light mode while preserving blur/transparency

import Service from 'resource:///com/github/Aylur/ags/service.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import GLib from 'gi://GLib';

const THEMES = {
    DARK: 'dark',
    LIGHT: 'light',
};

// Config file path
const CONFIG_DIR = GLib.get_user_config_dir() + '/hyprmac';
const THEME_FILE = CONFIG_DIR + '/theme.txt';

class ThemeService extends Service {
    static {
        Service.register(
            this,
            {
                'changed': [],
            },
            {
                'theme': ['string', 'rw'],
                'isDark': ['boolean', 'r'],
            }
        );
    }

    #theme = THEMES.DARK;

    get theme() {
        return this.#theme;
    }

    set theme(value) {
        if (!Object.values(THEMES).includes(value)) {
            console.error(`Invalid theme: ${value}`);
            return;
        }
        
        if (this.#theme === value) return;
        
        this.#theme = value;
        this.#applyTheme();
        this.#saveTheme();
        this.emit('changed');
        this.notify('theme');
        this.notify('isDark');
    }

    get isDark() {
        return this.#theme === THEMES.DARK;
    }

    toggle() {
        this.theme = this.isDark ? THEMES.LIGHT : THEMES.DARK;
    }

    #applyTheme() {
        // Apply theme class to all windows
        const windows = App.windows;
        for (const window of windows) {
            if (window.child) {
                window.child.toggleClassName('dark', this.isDark);
                window.child.toggleClassName('light', !this.isDark);
            }
        }
        
        // Also reload CSS with theme variables
        const cssPath = App.configDir + '/style.css';
        App.applyCss(cssPath);
        
        console.log(`Theme switched to ${this.#theme}`);
    }

    #saveTheme() {
        try {
            // Ensure config directory exists
            Utils.exec(`mkdir -p ${CONFIG_DIR}`);
            Utils.writeFile(this.#theme, THEME_FILE);
        } catch (e) {
            console.error('Failed to save theme:', e);
        }
    }

    #loadTheme() {
        try {
            const theme = Utils.readFile(THEME_FILE).trim();
            if (Object.values(THEMES).includes(theme)) {
                this.#theme = theme;
            }
        } catch {
            // File doesn't exist, use default (dark)
            this.#theme = THEMES.DARK;
        }
    }

    constructor() {
        super();
        this.#loadTheme();
        
        // Apply theme after a short delay to ensure windows are created
        Utils.timeout(100, () => {
            this.#applyTheme();
        });
    }
}

// Export themes enum
export const Themes = THEMES;

// Singleton export
const service = new ThemeService();
export default service;
