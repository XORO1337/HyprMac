from gi.repository import Gtk, Gdk
import os
import subprocess
import psutil

class DockWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.set_halign(Gtk.Align.CENTER)
        self.set_valign(Gtk.Align.END)
        self.set_margin_bottom(10)

        # Example apps: Add more as needed
        self.apps = [
            {'name': 'kitty', 'icon': 'terminal', 'command': 'kitty'},
            {'name': 'firefox', 'icon': 'firefox', 'command': 'firefox'},
            {'name': 'nautilus', 'icon': 'folder', 'command': 'nautilus'},
            {'name': 'code', 'icon': 'code', 'command': 'code'}
        ]

        self.buttons = []
        for app in self.apps:
            btn = self.create_app_button(app)
            self.buttons.append(btn)
            self.add(btn)

        # Update running indicators periodically
        from gi.repository import GLib
        GLib.timeout_add_seconds(2, self.update_running_indicators)

    def create_app_button(self, app):
        # Create overlay for indicator dot
        overlay = Gtk.Overlay()

        # Main icon button
        icon = Gtk.Image.new_from_icon_name(app['icon'], Gtk.IconSize.DIALOG)
        btn = Gtk.Button()
        btn.add(icon)
        btn.set_relief(Gtk.ReliefStyle.NONE)
        btn.connect('enter-notify-event', self.on_hover)
        btn.connect('leave-notify-event', self.on_leave)
        btn.connect('clicked', lambda b, cmd=app['command']: self.launch_app(cmd))
        btn.connect('button-press-event', lambda b, e, app=app: self.on_right_click(b, e, app))

        # Running indicator (small dot)
        self.running_indicator = Gtk.DrawingArea()
        self.running_indicator.set_size_request(8, 8)
        self.running_indicator.connect('draw', self.draw_indicator)

        # Position indicator at bottom-right of button
        overlay.add(btn)
        overlay.add_overlay(self.running_indicator)
        overlay.set_overlay_pass_through(self.running_indicator, True)

        # Store reference for updates
        btn.app_name = app['name']
        btn.running_indicator = self.running_indicator

        return overlay

    def launch_app(self, command):
        os.system(f'{command} &')

    def on_hover(self, widget, event):
        widget.set_scale(1.2, 1.2)  # macOS dock magnify

    def on_leave(self, widget, event):
        widget.set_scale(1.0, 1.0)

    def on_right_click(self, button, event, app):
        if event.button == 3:  # Right click
            menu = Gtk.Menu()

            # Force quit option
            quit_item = Gtk.MenuItem(label=f"Force Quit {app['name']}")
            quit_item.connect('activate', lambda w: self.force_quit_app(app['name']))
            menu.append(quit_item)

            menu.show_all()
            menu.popup_at_pointer(event)

    def force_quit_app(self, app_name):
        # Find and kill processes with this name
        for proc in psutil.process_iter(['pid', 'name']):
            if app_name.lower() in proc.info['name'].lower():
                try:
                    proc.kill()
                except:
                    pass

    def update_running_indicators(self):
        running_apps = set()
        for proc in psutil.process_iter(['name']):
            proc_name = proc.info['name'].lower()
            for app in self.apps:
                if app['name'].lower() in proc_name:
                    running_apps.add(app['name'])

        for overlay in self.buttons:
            btn = overlay.get_child()
            if hasattr(btn, 'app_name'):
                is_running = btn.app_name in running_apps
                btn.running_indicator.set_visible(is_running)

        return True

    def draw_indicator(self, widget, cr):
        # Draw blue dot indicator
        cr.set_source_rgba(0.2, 0.6, 1.0, 1.0)  # Blue color
        cr.arc(4, 4, 3, 0, 2 * 3.14159)
        cr.fill()