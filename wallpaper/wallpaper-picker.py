#!/usr/bin/env python3

"""
macOS Tahoe Wallpaper Picker
A GUI application for selecting and managing wallpapers with support for both images and videos.
"""

import os
import sys
import json
import subprocess
import threading
from pathlib import Path
from typing import List, Optional, Tuple

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GdkPixbuf', '2.0')
from gi.repository import Gtk, GdkPixbuf, Gdk, GLib

class WallpaperPicker:
    """Main wallpaper picker application."""
    
    def __init__(self):
        self.wallpaper_dir = Path.home() / 'Documents' / 'Wallpapers'
        self.config_file = Path.home() / '.config' / 'wallpaper' / 'config.json'
        self.thumbnail_dir = Path.home() / '.cache' / 'wallpaper-thumbnails'
        
        # Supported file formats
        self.image_formats = {'.jpg', '.jpeg', '.png', '.webp', '.bmp', '.gif'}
        self.video_formats = {'.mp4', '.webm', '.mkv', '.avi', '.mov'}
        
        # Create directories if they don't exist
        self.wallpaper_dir.mkdir(parents=True, exist_ok=True)
        self.thumbnail_dir.mkdir(parents=True, exist_ok=True)
        self.config_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Load configuration
        self.config = self.load_config()
        
        # Initialize GTK
        self.init_ui()
        
        # Load wallpapers
        self.load_wallpapers()
    
    def load_config(self) -> dict:
        """Load application configuration."""
        default_config = {
            'current_wallpaper': '',
            'video_wallpaper_engine': 'gSlapper',  # or 'mpvpaper'
            'image_wallpaper_engine': 'swww',      # or 'hyprpaper'
            'thumbnail_size': 200,
            'grid_columns': 4,
            'auto_start_video': True,
            'video_volume': 0.0,
            'slideshow_enabled': False,
            'slideshow_interval': 300,  # 5 minutes
        }
        
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r') as f:
                    config = json.load(f)
                    default_config.update(config)
            except (json.JSONDecodeError, IOError):
                pass
        
        return default_config
    
    def save_config(self):
        """Save application configuration."""
        try:
            with open(self.config_file, 'w') as f:
                json.dump(self.config, f, indent=2)
        except IOError as e:
            print(f"Error saving config: {e}")
    
    def init_ui(self):
        """Initialize the user interface."""
        # Create main window
        self.window = Gtk.Window(title="Wallpaper Picker")
        self.window.set_default_size(1200, 800)
        self.window.set_position(Gtk.WindowPosition.CENTER)
        self.window.set_icon_name('preferences-desktop-wallpaper')
        
        # Connect window events
        self.window.connect('destroy', Gtk.main_quit)
        self.window.connect('key-press-event', self.on_key_press)
        
        # Create main container
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.window.add(vbox)
        
        # Create header bar
        header = self.create_header_bar()
        vbox.pack_start(header, False, False, 0)
        
        # Create main content area
        self.create_main_content(vbox)
        
        # Create status bar
        self.status_bar = Gtk.Statusbar()
        vbox.pack_end(self.status_bar, False, False, 0)
        
        self.window.show_all()
    
    def create_header_bar(self) -> Gtk.HeaderBar:
        """Create the header bar with controls."""
        header = Gtk.HeaderBar()
        header.set_show_close_button(True)
        header.set_title("Wallpaper Picker")
        header.set_subtitle("Choose your desktop wallpaper")
        
        # Add refresh button
        refresh_btn = Gtk.Button.new_from_icon_name('view-refresh', Gtk.IconSize.BUTTON)
        refresh_btn.set_tooltip_text('Refresh wallpapers')
        refresh_btn.connect('clicked', self.on_refresh_clicked)
        header.pack_start(refresh_btn)
        
        # Add settings button
        settings_btn = Gtk.Button.new_from_icon_name('preferences-system', Gtk.IconSize.BUTTON)
        settings_btn.set_tooltip_text('Settings')
        settings_btn.connect('clicked', self.on_settings_clicked)
        header.pack_end(settings_btn)
        
        # Add add button
        add_btn = Gtk.Button.new_from_icon_name('list-add', Gtk.IconSize.BUTTON)
        add_btn.set_tooltip_text('Add wallpapers')
        add_btn.connect('clicked', self.on_add_clicked)
        header.pack_end(add_btn)
        
        return header
    
    def create_main_content(self, container: Gtk.Box):
        """Create the main content area."""
        # Create paned container
        paned = Gtk.Paned(orientation=Gtk.Orientation.HORIZONTAL)
        container.pack_start(paned, True, True, 0)
        
        # Create sidebar
        sidebar = self.create_sidebar()
        paned.pack1(sidebar, False, False)
        
        # Create wallpaper grid
        self.create_wallpaper_grid(paned)
        
        # Create preview panel
        preview = self.create_preview_panel()
        paned.pack2(preview, False, False)
    
    def create_sidebar(self) -> Gtk.ScrolledWindow:
        """Create the sidebar with categories."""
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_min_content_width(200)
        
        # Create list box for categories
        listbox = Gtk.ListBox()
        listbox.set_selection_mode(Gtk.SelectionMode.SINGLE)
        listbox.connect('row-selected', self.on_category_selected)
        scrolled.add(listbox)
        
        # Add categories
        categories = [
            ('all', 'All Wallpapers', 'folder'),
            ('images', 'Images', 'image-x-generic'),
            ('videos', 'Videos', 'video-x-generic'),
            ('favorites', 'Favorites', 'starred'),
            ('recent', 'Recent', 'document-open-recent'),
        ]
        
        for category_id, label, icon_name in categories:
            row = Gtk.ListBoxRow()
            box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
            box.set_margin_left(12)
            box.set_margin_right(12)
            box.set_margin_top(8)
            box.set_margin_bottom(8)
            
            icon = Gtk.Image.new_from_icon_name(icon_name, Gtk.IconSize.LARGE_TOOLBAR)
            label_widget = Gtk.Label(label)
            
            box.pack_start(icon, False, False, 0)
            box.pack_start(label_widget, True, True, 0)
            
            row.add(box)
            row.category_id = category_id
            listbox.add(row)
        
        # Select first category
        listbox.select_row(listbox.get_row_at_index(0))
        
        return scrolled
    
    def create_wallpaper_grid(self, container: Gtk.Paned):
        """Create the wallpaper grid view."""
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        
        # Create flow box for wallpapers
        self.flowbox = Gtk.FlowBox()
        self.flowbox.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.flowbox.set_activate_on_single_click(False)
        self.flowbox.set_homogeneous(True)
        self.flowbox.set_row_spacing(12)
        self.flowbox.set_column_spacing(12)
        self.flowbox.set_margin_top(12)
        self.flowbox.set_margin_bottom(12)
        self.flowbox.set_margin_left(12)
        self.flowbox.set_margin_right(12)
        
        # Connect events
        self.flowbox.connect('selected-children-changed', self.on_wallpaper_selected)
        self.flowbox.connect('child-activated', self.on_wallpaper_activated)
        
        scrolled.add(self.flowbox)
        container.pack2(scrolled, True, True)
    
    def create_preview_panel(self) -> Gtk.ScrolledWindow:
        """Create the preview panel."""
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_min_content_width(300)
        
        # Create main container
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        vbox.set_margin_top(12)
        vbox.set_margin_bottom(12)
        vbox.set_margin_left(12)
        vbox.set_margin_right(12)
        scrolled.add(vbox)
        
        # Preview image
        self.preview_image = Gtk.Image()
        self.preview_image.set_size_request(280, 200)
        vbox.pack_start(self.preview_image, False, False, 0)
        
        # Info box
        self.info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        vbox.pack_start(self.info_box, False, False, 0)
        
        # Action buttons
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        vbox.pack_end(button_box, False, False, 0)
        
        self.set_button = Gtk.Button(label='Set as Wallpaper')
        self.set_button.connect('clicked', self.on_set_wallpaper)
        button_box.pack_start(self.set_button, True, True, 0)
        
        self.favorite_button = Gtk.Button.new_from_icon_name('star', Gtk.IconSize.BUTTON)
        self.favorite_button.connect('clicked', self.on_toggle_favorite)
        button_box.pack_start(self.favorite_button, False, False, 0)
        
        return scrolled
    
    def load_wallpapers(self):
        """Load all wallpapers from the wallpaper directory."""
        self.wallpapers = []
        
        # Scan wallpaper directory
        for file_path in self.wallpaper_dir.rglob('*'):
            if file_path.is_file() and file_path.suffix.lower() in self.image_formats | self.video_formats:
                self.wallpapers.append({
                    'path': file_path,
                    'name': file_path.stem,
                    'type': 'video' if file_path.suffix.lower() in self.video_formats else 'image',
                    'thumbnail': None,
                    'favorite': False,
                    'modified': file_path.stat().st_mtime
                })
        
        # Sort by modification time (newest first)
        self.wallpapers.sort(key=lambda x: x['modified'], reverse=True)
        
        # Update display
        self.update_wallpaper_grid()
        
        # Update status
        self.update_status(f"Loaded {len(self.wallpapers)} wallpapers")
    
    def update_wallpaper_grid(self):
        """Update the wallpaper grid display."""
        # Clear existing children
        for child in self.flowbox.get_children():
            self.flowbox.remove(child)
        
        # Add wallpapers to grid
        for wallpaper in self.wallpapers:
            child = self.create_wallpaper_child(wallpaper)
            self.flowbox.add(child)
        
        self.flowbox.show_all()
    
    def create_wallpaper_child(self, wallpaper: dict) -> Gtk.FlowBoxChild:
        """Create a child widget for a wallpaper."""
        child = Gtk.FlowBoxChild()
        child.wallpaper = wallpaper
        
        # Create container
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        
        # Thumbnail
        thumbnail = Gtk.Image()
        thumbnail.set_size_request(self.config['thumbnail_size'], 
                                   self.config['thumbnail_size'])
        
        # Generate or load thumbnail
        self.load_thumbnail(wallpaper, thumbnail)
        
        vbox.pack_start(thumbnail, True, True, 0)
        
        # Label
        label = Gtk.Label(wallpaper['name'])
        label.set_ellipsize(True)
        label.set_max_width_chars(20)
        label.set_tooltip_text(str(wallpaper['path']))
        vbox.pack_start(label, False, False, 4)
        
        child.add(vbox)
        
        return child
    
    def load_thumbnail(self, wallpaper: dict, image: Gtk.Image):
        """Load or generate thumbnail for a wallpaper."""
        thumbnail_path = self.thumbnail_dir / f"{wallpaper['path'].stem}.jpg"
        
        if thumbnail_path.exists():
            # Load existing thumbnail
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(str(thumbnail_path))
                image.set_from_pixbuf(pixbuf)
                return
            except Exception:
                pass
        
        # Generate thumbnail in background
        threading.Thread(
            target=self.generate_thumbnail,
            args=(wallpaper, image, thumbnail_path),
            daemon=True
        ).start()
    
    def generate_thumbnail(self, wallpaper: dict, image: Gtk.Image, thumbnail_path: Path):
        """Generate thumbnail for wallpaper."""
        try:
            if wallpaper['type'] == 'video':
                # Extract frame from video at 10 seconds
                cmd = [
                    'ffmpeg', '-ss', '10', '-i', str(wallpaper['path']),
                    '-vframes', '1', '-vf', f'scale={self.config["thumbnail_size"]}:-1',
                    '-y', str(thumbnail_path)
                ]
            else:
                # Resize image
                cmd = [
                    'convert', str(wallpaper['path']),
                    '-resize', f'{self.config["thumbnail_size"]}x{self.config["thumbnail_size"]}>',
                    str(thumbnail_path)
                ]
            
            subprocess.run(cmd, capture_output=True, check=True)
            
            # Update UI in main thread
            GLib.idle_add(lambda: self.update_thumbnail(image, thumbnail_path))
            
        except subprocess.CalledProcessError as e:
            print(f"Error generating thumbnail: {e}")
            # Use fallback icon
            GLib.idle_add(lambda: image.set_from_icon_name(
                'image-x-generic' if wallpaper['type'] == 'image' else 'video-x-generic',
                Gtk.IconSize.LARGE_TOOLBAR
            ))
    
    def update_thumbnail(self, image: Gtk.Image, thumbnail_path: Path):
        """Update thumbnail in UI."""
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(str(thumbnail_path))
            image.set_from_pixbuf(pixbuf)
        except Exception:
            pass
        return False
    
    def on_category_selected(self, listbox: Gtk.ListBox, row: Gtk.ListBoxRow):
        """Handle category selection."""
        if not row:
            return
        
        category = row.category_id
        
        # Filter wallpapers by category
        if category == 'all':
            filtered = self.wallpapers
        elif category == 'images':
            filtered = [w for w in self.wallpapers if w['type'] == 'image']
        elif category == 'videos':
            filtered = [w for w in self.wallpapers if w['type'] == 'video']
        elif category == 'favorites':
            filtered = [w for w in self.wallpapers if w['favorite']]
        elif category == 'recent':
            # Show last 10 modified
            filtered = self.wallpapers[:10]
        else:
            filtered = self.wallpapers
        
        # Update grid
        self.update_wallpaper_grid()
        
        self.update_status(f"Showing {len(filtered)} wallpapers")
    
    def on_wallpaper_selected(self, flowbox: Gtk.FlowBox):
        """Handle wallpaper selection."""
        selected = flowbox.get_selected_children()
        if not selected:
            return
        
        wallpaper = selected[0].wallpaper
        self.selected_wallpaper = wallpaper
        
        # Update preview
        self.update_preview(wallpaper)
    
    def on_wallpaper_activated(self, flowbox: Gtk.FlowBox, child: Gtk.FlowBoxChild):
        """Handle wallpaper double-click/activation."""
        wallpaper = child.wallpaper
        self.set_wallpaper(wallpaper)
    
    def update_preview(self, wallpaper: dict):
        """Update the preview panel."""
        # Update preview image
        self.load_preview_image(wallpaper)
        
        # Update info
        for child in self.info_box.get_children():
            self.info_box.remove(child)
        
        # File info
        stat = wallpaper['path'].stat()
        info_labels = [
            ('Name', wallpaper['name']),
            ('Type', wallpaper['type'].title()),
            ('Path', str(wallpaper['path'])),
            ('Size', f"{stat.st_size / 1024 / 1024:.1f} MB"),
            ('Modified', wallpaper['path'].stat().st_mtime),
        ]
        
        for label, value in info_labels:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            
            label_widget = Gtk.Label(f"{label}:")
            label_widget.set_alignment(0, 0.5)
            label_widget.set_width_chars(12)
            hbox.pack_start(label_widget, False, False, 0)
            
            value_widget = Gtk.Label(str(value))
            value_widget.set_alignment(0, 0.5)
            value_widget.set_ellipsize(True)
            hbox.pack_start(value_widget, True, True, 0)
            
            self.info_box.pack_start(hbox, False, False, 0)
        
        self.info_box.show_all()
    
    def load_preview_image(self, wallpaper: dict):
        """Load preview image for wallpaper."""
        thumbnail_path = self.thumbnail_dir / f"{wallpaper['path'].stem}.jpg"
        
        if thumbnail_path.exists():
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(str(thumbnail_path))
                # Scale to preview size
                scaled = pixbuf.scale_simple(280, 200, GdkPixbuf.InterpType.BILINEAR)
                self.preview_image.set_from_pixbuf(scaled)
            except Exception:
                self.preview_image.set_from_icon_name(
                    'image-x-generic' if wallpaper['type'] == 'image' else 'video-x-generic',
                    Gtk.IconSize.LARGE_TOOLBAR
                )
    
    def on_refresh_clicked(self, button: Gtk.Button):
        """Handle refresh button click."""
        self.load_wallpapers()
    
    def on_settings_clicked(self, button: Gtk.Button):
        """Handle settings button click."""
        # TODO: Implement settings dialog
        dialog = Gtk.MessageDialog(
            parent=self.window,
            flags=Gtk.DialogFlags.MODAL,
            type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            message_format="Settings dialog not yet implemented"
        )
        dialog.run()
        dialog.destroy()
    
    def on_add_clicked(self, button: Gtk.Button):
        """Handle add button click."""
        dialog = Gtk.FileChooserDialog(
            title="Add Wallpapers",
            parent=self.window,
            action=Gtk.FileChooserAction.OPEN
        )
        
        dialog.add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL)
        dialog.add_button(Gtk.STOCK_OPEN, Gtk.ResponseType.ACCEPT)
        
        # Set file filters
        filter_all = Gtk.FileFilter()
        filter_all.set_name("All Supported Files")
        for ext in self.image_formats | self.video_formats:
            filter_all.add_pattern(f"*{ext}")
        dialog.add_filter(filter_all)
        
        filter_images = Gtk.FileFilter()
        filter_images.set_name("Images")
        for ext in self.image_formats:
            filter_images.add_pattern(f"*{ext}")
        dialog.add_filter(filter_images)
        
        filter_videos = Gtk.FileFilter()
        filter_videos.set_name("Videos")
        for ext in self.video_formats:
            filter_videos.add_pattern(f"*{ext}")
        dialog.add_filter(filter_videos)
        
        dialog.set_select_multiple(True)
        
        if dialog.run() == Gtk.ResponseType.ACCEPT:
            files = dialog.get_filenames()
            self.add_wallpapers(files)
        
        dialog.destroy()
    
    def add_wallpapers(self, files: List[str]):
        """Add wallpapers to the collection."""
        for file_path in files:
            src = Path(file_path)
            dst = self.wallpaper_dir / src.name
            
            try:
                # Copy file
                import shutil
                shutil.copy2(src, dst)
                
                # Add to list
                wallpaper = {
                    'path': dst,
                    'name': src.stem,
                    'type': 'video' if src.suffix.lower() in self.video_formats else 'image',
                    'thumbnail': None,
                    'favorite': False,
                    'modified': dst.stat().st_mtime
                }
                
                self.wallpapers.insert(0, wallpaper)
                
                print(f"Added wallpaper: {src.name}")
                
            except Exception as e:
                print(f"Error adding wallpaper {src}: {e}")
        
        # Update display
        self.update_wallpaper_grid()
        self.update_status(f"Added {len(files)} wallpapers")
    
    def on_set_wallpaper(self, button: Gtk.Button):
        """Handle set wallpaper button click."""
        if hasattr(self, 'selected_wallpaper'):
            self.set_wallpaper(self.selected_wallpaper)
    
    def on_toggle_favorite(self, button: Gtk.Button):
        """Handle toggle favorite button click."""
        if hasattr(self, 'selected_wallpaper'):
            self.selected_wallpaper['favorite'] = not self.selected_wallpaper['favorite']
            self.update_preview(self.selected_wallpaper)
    
    def set_wallpaper(self, wallpaper: dict):
        """Set the wallpaper."""
        try:
            if wallpaper['type'] == 'video':
                # Set video wallpaper using gSlapper
                self.set_video_wallpaper(wallpaper['path'])
            else:
                # Set image wallpaper using swww
                self.set_image_wallpaper(wallpaper['path'])
            
            # Save current wallpaper
            self.config['current_wallpaper'] = str(wallpaper['path'])
            self.save_config()
            
            self.update_status(f"Set wallpaper: {wallpaper['name']}")
            
        except Exception as e:
            print(f"Error setting wallpaper: {e}")
            self.update_status(f"Error setting wallpaper: {e}")
    
    def set_image_wallpaper(self, image_path: Path):
        """Set image wallpaper using swww."""
        cmd = ['swww', 'img', str(image_path)]
        subprocess.run(cmd, check=True)
    
    def set_video_wallpaper(self, video_path: Path):
        """Set video wallpaper using gSlapper."""
        cmd = ['gSlapper', str(video_path)]
        subprocess.run(cmd, check=True)
    
    def on_key_press(self, window: Gtk.Window, event: Gdk.EventKey):
        """Handle key press events."""
        keyval = event.keyval
        
        if keyval == Gdk.KEY_Escape:
            self.window.close()
        elif keyval == Gdk.KEY_F5:
            self.load_wallpapers()
        elif keyval == Gdk.KEY_Delete:
            if hasattr(self, 'selected_wallpaper'):
                self.delete_wallpaper(self.selected_wallpaper)
    
    def delete_wallpaper(self, wallpaper: dict):
        """Delete a wallpaper."""
        dialog = Gtk.MessageDialog(
            parent=self.window,
            flags=Gtk.DialogFlags.MODAL,
            type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.YES_NO,
            message_format=f"Delete {wallpaper['name']}?"
        )
        
        response = dialog.run()
        dialog.destroy()
        
        if response == Gtk.ResponseType.YES:
            try:
                wallpaper['path'].unlink()
                self.wallpapers.remove(wallpaper)
                self.update_wallpaper_grid()
                self.update_status(f"Deleted: {wallpaper['name']}")
            except Exception as e:
                print(f"Error deleting wallpaper: {e}")
    
    def update_status(self, message: str):
        """Update the status bar."""
        context_id = self.status_bar.get_context_id('main')
        self.status_bar.push(context_id, message)
    
    def run(self):
        """Run the application."""
        Gtk.main()


def main():
    """Main entry point."""
    app = WallpaperPicker()
    app.run()


if __name__ == '__main__':
    main()