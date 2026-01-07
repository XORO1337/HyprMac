// Wallpaper Picker Widget for HyprMac
// Displays all images and video wallpapers for selection

import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import Theme from '../services/theme.js';
import WallpaperColors from '../services/wallpaper-colors.js';

// Wallpaper directory - users can change this
const WALLPAPER_DIR = GLib.get_home_dir() + '/Pictures/wallpapers';
const CACHE_DIR = GLib.get_user_cache_dir() + '/hyprmac/thumbnails';

// Supported formats
const IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp'];
const VIDEO_EXTENSIONS = ['.mp4', '.webm', '.mkv', '.avi', '.mov'];
const ALL_EXTENSIONS = [...IMAGE_EXTENSIONS, ...VIDEO_EXTENSIONS];

// State variables
const Wallpapers = Variable([]);
const SelectedWallpaper = Variable('');
const IsLoading = Variable(false);
const SearchQuery = Variable('');

// Check if file is a supported wallpaper
const isWallpaper = (filename) => {
    const ext = filename.toLowerCase().slice(filename.lastIndexOf('.'));
    return ALL_EXTENSIONS.includes(ext);
};

// Check if file is a video
const isVideo = (filename) => {
    const ext = filename.toLowerCase().slice(filename.lastIndexOf('.'));
    return VIDEO_EXTENSIONS.includes(ext);
};

// Generate thumbnail for video using ffmpeg
const generateVideoThumbnail = async (videoPath, thumbPath) => {
    try {
        // Extract frame at 2 seconds for thumbnail (faster preview)
        await Utils.execAsync([
            'ffmpeg', '-y', '-i', videoPath,
            '-ss', '2', '-vframes', '1',
            '-vf', 'scale=200:-1',
            thumbPath
        ]);
        return true;
    } catch (e) {
        console.error(`Failed to generate thumbnail for ${videoPath}:`, e);
        return false;
    }
};

// Get thumbnail path for a wallpaper
const getThumbnailPath = (wallpaperPath) => {
    const filename = wallpaperPath.split('/').pop();
    const thumbName = filename.replace(/\.[^.]+$/, '.png');
    return `${CACHE_DIR}/${thumbName}`;
};

// Load all wallpapers from directory
const loadWallpapers = async () => {
    IsLoading.value = true;
    
    try {
        // Ensure directories exist
        Utils.exec(`mkdir -p "${WALLPAPER_DIR}"`);
        Utils.exec(`mkdir -p "${CACHE_DIR}"`);
        
        // Get list of files
        const files = Utils.exec(`find "${WALLPAPER_DIR}" -maxdepth 2 -type f 2>/dev/null || true`);
        
        const wallpaperList = files
            .split('\n')
            .filter(f => f && isWallpaper(f))
            .map(path => ({
                path,
                name: path.split('/').pop(),
                isVideo: isVideo(path),
                thumbnail: isVideo(path) ? getThumbnailPath(path) : path,
            }));
        
        // Generate thumbnails for videos in background
        for (const wp of wallpaperList) {
            if (wp.isVideo) {
                const thumbPath = wp.thumbnail;
                // Check if thumbnail exists
                const thumbFile = Gio.File.new_for_path(thumbPath);
                if (!thumbFile.query_exists(null)) {
                    generateVideoThumbnail(wp.path, thumbPath);
                }
            }
        }
        
        Wallpapers.value = wallpaperList;
    } catch (e) {
        console.error('Failed to load wallpapers:', e);
        Wallpapers.value = [];
    }
    
    IsLoading.value = false;
};

// Set wallpaper using swww (for images) or gslapper (for videos)
const setWallpaper = async (wallpaper) => {
    SelectedWallpaper.value = wallpaper.path;
    
    try {
        if (wallpaper.isVideo) {
            // Kill any existing video wallpaper players
            Utils.exec('pkill -f mpvpaper || true');
            Utils.exec('pkill -f gslapper || true');
            
            // Use gslapper for video wallpapers
            Utils.execAsync([
                'gslapper', '-o', 'loop', '',
                wallpaper.path
            ]).catch(err => {
                console.error('Failed to start gslapper:', err);
                console.error('Make sure gslapper is installed: yay -S gslapper');
            });
        } else {
            // Kill any video wallpaper players before setting image
            Utils.exec('pkill -f mpvpaper || true');
            Utils.exec('pkill -f gslapper || true');
            
            // Set image wallpaper with swww
            Utils.execAsync([
                'swww', 'img', wallpaper.path,
                '--transition-type', 'wipe',
                '--transition-fps', '60',
                '--transition-duration', '1.5'
            ]).catch(err => {
                console.error('Failed to set wallpaper with swww:', err);
            });
        }
        
        // Update symlink for current wallpaper
        const currentPath = GLib.get_home_dir() + '/Pictures/wallpaper/current';
        Utils.exec(`mkdir -p "${GLib.get_home_dir()}/Pictures/wallpaper"`);
        Utils.exec(`rm -f "${currentPath}"`);
        Utils.exec(`ln -sf "${wallpaper.path}" "${currentPath}"`);
        
        // Extract colors from new wallpaper
        WallpaperColors.wallpaper = wallpaper.path;
        
    } catch (e) {
        console.error('Failed to set wallpaper:', e);
    }
};

// Refresh wallpapers
const refreshWallpapers = () => {
    loadWallpapers();
};

// Wallpaper Item Widget
const WallpaperItem = (wallpaper) => {
    const thumbFile = Gio.File.new_for_path(wallpaper.thumbnail);
    const hasThumb = !wallpaper.isVideo || thumbFile.query_exists(null);
    
    return Widget.Button({
        className: 'wallpaper-item',
        tooltipText: wallpaper.name,
        onClicked: () => {
            setWallpaper(wallpaper);
            // Close picker after selection (optional - can be removed)
            // App.closeWindow('wallpaper-picker');
        },
        setup: self => {
            self.hook(SelectedWallpaper, () => {
                self.toggleClassName('selected', SelectedWallpaper.value === wallpaper.path);
            });
        },
        child: Widget.Box({
            vertical: true,
            children: [
                Widget.Box({
                    className: 'wallpaper-thumbnail',
                    css: hasThumb ? `
                        background-image: url('${wallpaper.thumbnail}');
                        background-size: cover;
                        background-position: center;
                        min-width: 160px;
                        min-height: 90px;
                    ` : `
                        background-color: #313244;
                        min-width: 160px;
                        min-height: 90px;
                    `,
                    child: wallpaper.isVideo ? Widget.Icon({
                        icon: 'media-playback-start-symbolic',
                        className: 'video-indicator',
                        size: 24,
                    }) : null,
                }),
                Widget.Label({
                    className: 'wallpaper-name',
                    label: wallpaper.name.length > 18 
                        ? wallpaper.name.slice(0, 15) + '...' 
                        : wallpaper.name,
                    truncate: 'end',
                    maxWidthChars: 18,
                }),
            ],
        }),
    });
};

// Search/Filter Bar
const SearchBar = () => Widget.Box({
    className: 'wallpaper-search-bar',
    children: [
        Widget.Icon({
            icon: 'system-search-symbolic',
            className: 'search-icon',
        }),
        Widget.Entry({
            className: 'wallpaper-search',
            placeholder_text: 'Search wallpapers...',
            hexpand: true,
            onChange: ({ text }) => SearchQuery.value = text || '',
        }),
        Widget.Button({
            className: 'refresh-button',
            tooltipText: 'Refresh wallpapers',
            onClicked: refreshWallpapers,
            child: Widget.Icon({
                icon: 'view-refresh-symbolic',
                size: 18,
            }),
        }),
    ],
});

// Filter Tabs
const FilterTabs = () => {
    const FilterTab = Variable('all'); // 'all', 'images', 'videos'
    
    return Widget.Box({
        className: 'wallpaper-filter-tabs',
        homogeneous: true,
        children: [
            Widget.Button({
                className: 'filter-tab',
                label: 'All',
                setup: self => self.hook(FilterTab, () => {
                    self.toggleClassName('active', FilterTab.value === 'all');
                }),
                onClicked: () => FilterTab.value = 'all',
            }),
            Widget.Button({
                className: 'filter-tab',
                label: 'Images',
                setup: self => self.hook(FilterTab, () => {
                    self.toggleClassName('active', FilterTab.value === 'images');
                }),
                onClicked: () => FilterTab.value = 'images',
            }),
            Widget.Button({
                className: 'filter-tab',
                label: 'Videos',
                setup: self => self.hook(FilterTab, () => {
                    self.toggleClassName('active', FilterTab.value === 'videos');
                }),
                onClicked: () => FilterTab.value = 'videos',
            }),
        ],
    });
};

// Wallpaper Grid
const WallpaperGrid = () => {
    const filterType = Variable('all');
    
    return Widget.Box({
        vertical: true,
        children: [
            // Filter tabs
            Widget.Box({
                className: 'wallpaper-filter-tabs',
                homogeneous: true,
                children: [
                    Widget.Button({
                        className: 'filter-tab',
                        label: 'All',
                        setup: self => self.hook(filterType, () => {
                            self.toggleClassName('active', filterType.value === 'all');
                        }),
                        onClicked: () => filterType.value = 'all',
                    }),
                    Widget.Button({
                        className: 'filter-tab',
                        label: 'Images',
                        setup: self => self.hook(filterType, () => {
                            self.toggleClassName('active', filterType.value === 'images');
                        }),
                        onClicked: () => filterType.value = 'images',
                    }),
                    Widget.Button({
                        className: 'filter-tab',
                        label: 'Videos',
                        setup: self => self.hook(filterType, () => {
                            self.toggleClassName('active', filterType.value === 'videos');
                        }),
                        onClicked: () => filterType.value = 'videos',
                    }),
                ],
            }),
            
            // Scrollable grid
            Widget.Scrollable({
                className: 'wallpaper-scroll',
                hscroll: 'never',
                vscroll: 'automatic',
                vexpand: true,
                child: Widget.Box({
                    className: 'wallpaper-grid',
                    css: 'min-width: 720px;',
                    setup: self => {
                        const updateGrid = () => {
                            const search = SearchQuery.value.toLowerCase();
                            const filter = filterType.value;
                            
                            let filtered = Wallpapers.value.filter(wp => {
                                // Apply search filter
                                if (search && !wp.name.toLowerCase().includes(search)) {
                                    return false;
                                }
                                // Apply type filter
                                if (filter === 'images' && wp.isVideo) return false;
                                if (filter === 'videos' && !wp.isVideo) return false;
                                return true;
                            });
                            
                            // Create rows of 4 items each for grid layout
                            const rows = [];
                            for (let i = 0; i < filtered.length; i += 4) {
                                rows.push(Widget.Box({
                                    className: 'wallpaper-row',
                                    homogeneous: true,
                                    children: filtered.slice(i, i + 4).map(WallpaperItem),
                                }));
                            }
                            
                            self.children = rows;
                        };
                        
                        self.hook(Wallpapers, updateGrid);
                        self.hook(SearchQuery, updateGrid);
                        self.hook(filterType, updateGrid);
                    },
                    vertical: true,
                }),
            }),
        ],
    });
};

// Loading Indicator
const LoadingIndicator = () => Widget.Box({
    className: 'loading-indicator',
    hpack: 'center',
    vpack: 'center',
    vexpand: true,
    hexpand: true,
    vertical: true,
    visible: IsLoading.bind(),
    children: [
        Widget.Spinner({
            className: 'loading-spinner',
            active: true,
        }),
        Widget.Label({
            label: 'Loading wallpapers...',
            className: 'loading-text',
        }),
    ],
});

// Empty State
const EmptyState = () => Widget.Box({
    className: 'empty-state',
    hpack: 'center',
    vpack: 'center',
    vexpand: true,
    vertical: true,
    children: [
        Widget.Icon({
            icon: 'folder-pictures-symbolic',
            size: 64,
            className: 'empty-icon',
        }),
        Widget.Label({
            label: 'No wallpapers found',
            className: 'empty-title',
        }),
        Widget.Label({
            label: `Add images or videos to:\n${WALLPAPER_DIR}`,
            className: 'empty-subtitle',
            justification: 'center',
        }),
        Widget.Button({
            className: 'open-folder-button',
            label: 'Open Folder',
            onClicked: () => Utils.execAsync(['xdg-open', WALLPAPER_DIR]),
        }),
    ],
});

// Header with close button
const Header = () => Widget.Box({
    className: 'wallpaper-picker-header',
    children: [
        Widget.Label({
            label: 'Wallpapers',
            className: 'header-title',
            hexpand: true,
            xalign: 0,
        }),
        Widget.Button({
            className: 'close-button',
            onClicked: () => App.closeWindow('wallpaper-picker'),
            child: Widget.Icon({
                icon: 'window-close-symbolic',
                size: 18,
            }),
        }),
    ],
});

// Color Preview Panel
const ColorPreview = () => Widget.Box({
    className: 'color-preview',
    vertical: true,
    children: [
        Widget.Label({
            label: 'Extracted Colors',
            className: 'color-preview-title',
            xalign: 0,
        }),
        Widget.Box({
            className: 'color-swatches',
            homogeneous: true,
            setup: self => self.hook(WallpaperColors, () => {
                const colors = WallpaperColors.colors;
                self.children = [
                    Widget.Box({ className: 'color-swatch', css: `background-color: ${colors.primary};`, tooltipText: 'Primary' }),
                    Widget.Box({ className: 'color-swatch', css: `background-color: ${colors.secondary};`, tooltipText: 'Secondary' }),
                    Widget.Box({ className: 'color-swatch', css: `background-color: ${colors.tertiary};`, tooltipText: 'Tertiary' }),
                    Widget.Box({ className: 'color-swatch', css: `background-color: ${colors.background};`, tooltipText: 'Background' }),
                    Widget.Box({ className: 'color-swatch', css: `background-color: ${colors.surface};`, tooltipText: 'Surface' }),
                    Widget.Box({ className: 'color-swatch', css: `background-color: ${colors.text};`, tooltipText: 'Text' }),
                ];
            }),
        }),
        Widget.Box({
            className: 'color-toggle-row',
            children: [
                Widget.Label({
                    label: 'Apply dynamic colors',
                    hexpand: true,
                    xalign: 0,
                }),
                Widget.Switch({
                    className: 'dynamic-colors-switch',
                    setup: self => self.hook(WallpaperColors, () => {
                        self.active = WallpaperColors.dynamicEnabled;
                    }),
                    onActivate: self => {
                        WallpaperColors.dynamicEnabled = self.active;
                    },
                }),
            ],
        }),
    ],
});

// Main Wallpaper Picker Window
export const WallpaperPicker = () => Widget.Window({
    name: 'wallpaper-picker',
    anchor: ['top', 'bottom', 'left', 'right'],
    className: 'wallpaper-picker-window',
    visible: false,
    keymode: 'exclusive',
    layer: 'overlay',
    exclusivity: 'ignore',
    setup: self => {
        self.keybind('Escape', () => App.closeWindow('wallpaper-picker'));
        // Load wallpapers when window opens
        self.hook(App, (_, windowName, visible) => {
            if (windowName === 'wallpaper-picker' && visible) {
                loadWallpapers();
            }
        }, 'window-toggled');
    },
    child: Widget.Box({
        className: 'wallpaper-picker-overlay',
        hpack: 'center',
        vpack: 'center',
        child: Widget.Box({
            className: 'wallpaper-picker',
            vertical: true,
            setup: self => {
                self.hook(Theme, () => {
                    self.toggleClassName('dark', Theme.isDark);
                    self.toggleClassName('light', !Theme.isDark);
                });
                self.hook(WallpaperColors, () => {
                    self.toggleClassName('dynamic-colors', WallpaperColors.dynamicEnabled);
                });
            },
            children: [
                Header(),
                SearchBar(),
                Widget.Box({
                    className: 'wallpaper-content',
                    vexpand: true,
                    children: [
                        Widget.Stack({
                            className: 'wallpaper-stack',
                            hexpand: true,
                            transition: 'crossfade',
                            shown: Variable.derive(
                                [IsLoading, Wallpapers],
                                (loading, wallpapers) => {
                                    if (loading) return 'loading';
                                    if (wallpapers.length === 0) return 'empty';
                                    return 'grid';
                                }
                            ).bind(),
                            children: {
                                'loading': LoadingIndicator(),
                                'empty': EmptyState(),
                                'grid': WallpaperGrid(),
                            },
                        }),
                    ],
                }),
                ColorPreview(),
            ],
        }),
    }),
});
