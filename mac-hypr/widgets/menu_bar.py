from fabric.widgets import Box, Label
from fabric.widgets.hyprland import Workspaces, WorkspaceButton
from fabric.widgets.widget import Widget
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import psutil
import subprocess
import json

class MenuBarWidget(Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, style="menu-bar")
        self.set_halign(Gtk.Align.FILL)
        self.set_valign(Gtk.Align.START)

        # Left: Workspaces
        def buttons_factory(workspace_id):
            return WorkspaceButton(id=workspace_id, label=str(workspace_id))

        self.workspaces = Workspaces(buttons_factory=buttons_factory)
        left_box = Gtk.Box(halign=Gtk.Align.START)
        left_box.add(self.workspaces)
        self.add(left_box)

        # Center: Window Title and Controls
        center_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, halign=Gtk.Align.CENTER, hexpand=True, spacing=5)
        
        # Window control buttons (macOS style)
        self.minimize_btn = Gtk.Button(label="🟡")
        self.minimize_btn.set_relief(Gtk.ReliefStyle.NONE)
        self.minimize_btn.set_size_request(12, 12)
        self.minimize_btn.connect('clicked', lambda b: self.window_control('minimize'))
        
        self.maximize_btn = Gtk.Button(label="🟢")
        self.maximize_btn.set_relief(Gtk.ReliefStyle.NONE)
        self.maximize_btn.set_size_request(12, 12)
        self.maximize_btn.connect('clicked', lambda b: self.window_control('maximize'))
        
        self.close_btn = Gtk.Button(label="🔴")
        self.close_btn.set_relief(Gtk.ReliefStyle.NONE)
        self.close_btn.set_size_request(12, 12)
        self.close_btn.connect('clicked', lambda b: self.window_control('close'))
        
        controls_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        controls_box.add(self.close_btn)
        controls_box.add(self.minimize_btn)
        controls_box.add(self.maximize_btn)
        
        self.title_label = Label(label="No Active Window")
        
        center_box.add(controls_box)
        center_box.add(self.title_label)
        self.add(center_box)

        # Right: Status Icons
        right_box = Gtk.Box(halign=Gtk.Align.END)
        self.volume_label = Label(label="Vol: --%")
        self.network_label = Label(label="Net: --")
        self.battery_label = Label(label="Bat: --%")
        self.ram_label = Label(label="RAM: --%")
        self.cpu_label = Label(label="CPU: --%")
        self.clock_label = Label(label="--:-- --")

        right_box.add(self.volume_label)
        right_box.add(self.network_label)
        right_box.add(self.battery_label)
        right_box.add(self.ram_label)
        right_box.add(self.cpu_label)
        right_box.add(self.clock_label)
        self.add(right_box)

        # Periodic Updates
        GLib.timeout_add_seconds(1, self.update_status)
        GLib.timeout_add_seconds(5, self.update_title)  # Less frequent for title

    def update_title(self):
        try:
            output = subprocess.check_output(["hyprctl", "activewindow", "-j"]).decode()
            data = json.loads(output)
            title = data.get("title", "No Active Window")[:50]  # Truncate long titles
            self.title_label.set_label(title)
            
            # Enable/disable window controls based on active window
            has_window = data.get("title") is not None
            self.minimize_btn.set_sensitive(has_window)
            self.maximize_btn.set_sensitive(has_window)
            self.close_btn.set_sensitive(has_window)
        except Exception:
            self.title_label.set_label("Error")
            self.minimize_btn.set_sensitive(False)
            self.maximize_btn.set_sensitive(False)
            self.close_btn.set_sensitive(False)
        return True

    def window_control(self, action):
        try:
            if action == 'minimize':
                subprocess.run(["hyprctl", "dispatch", "minimize", "active"])
            elif action == 'maximize':
                subprocess.run(["hyprctl", "dispatch", "fullscreen", "active"])
            elif action == 'close':
                subprocess.run(["hyprctl", "dispatch", "closewindow", "active"])
        except Exception as e:
            print(f"Window control error: {e}")

    def update_status(self):
        from datetime import datetime

        # Clock with icon
        self.clock_label.set_markup(f"<span font_desc='14'> {datetime.now().strftime('%I:%M %p')}</span>")

        # CPU with icon
        cpu = psutil.cpu_percent()
        self.cpu_label.set_markup(f"<span font_desc='14'> {cpu}%</span>")

        # RAM with icon
        ram = psutil.virtual_memory().percent
        self.ram_label.set_markup(f"<span font_desc='14'> {ram}%</span>")

        # Battery with dynamic icons
        bat = psutil.sensors_battery()
        if bat:
            percent = bat.percent
            charging = " " if bat.power_plugged else ""
            if percent <= 10:
                bat_icon = " "
            elif percent <= 30:
                bat_icon = " "
            elif percent <= 50:
                bat_icon = " "
            elif percent <= 80:
                bat_icon = " "
            else:
                bat_icon = " "
            self.battery_label.set_markup(f"<span font_desc='14'>{charging}{bat_icon}{percent}%</span>")
        else:
            self.battery_label.set_markup("<span font_desc='14'> N/A</span>")

        # Network with icons
        stats = psutil.net_if_stats()
        wifi_connected = any('wlan' in iface or 'wifi' in iface for iface in stats if stats[iface].isup)
        eth_connected = any('eth' in iface or 'en' in iface for iface in stats if stats[iface].isup)
        if wifi_connected:
            net_icon = " "
        elif eth_connected:
            net_icon = " "
        else:
            net_icon = "⚠ "
        self.network_label.set_markup(f"<span font_desc='14'>{net_icon}Net</span>")

        # Volume with icon
        try:
            output = subprocess.check_output("pactl get-sink-volume @DEFAULT_SINK@", shell=True).decode()
            vol = int(output.split()[4].strip('%'))
            vol_icon = " " if vol > 0 else " "
            self.volume_label.set_markup(f"<span font_desc='14'>{vol_icon}{vol}%</span>")
        except Exception:
            self.volume_label.set_markup("<span font_desc='14'> Error</span>")

        return True