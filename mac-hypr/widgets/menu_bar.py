import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import psutil
import subprocess
import json

class MenuBarWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL)
        self.get_style_context().add_class('menu-bar')
        self.set_halign(Gtk.Align.FILL)
        self.set_valign(Gtk.Align.START)

        # Left: Workspaces
        self.workspaces_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        self.workspaces_box.set_halign(Gtk.Align.START)
        self.workspace_buttons = []
        self.update_workspaces()
        self.pack_start(self.workspaces_box, False, False, 10)

        # Center: Window Title and Controls
        center_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        center_box.set_halign(Gtk.Align.CENTER)
        center_box.set_hexpand(True)
        
        # Window control buttons (macOS style)
        self.close_btn = Gtk.Button(label="●")
        self.close_btn.set_relief(Gtk.ReliefStyle.NONE)
        self.close_btn.get_style_context().add_class('window-close')
        self.close_btn.connect('clicked', lambda b: self.window_control('close'))
        
        self.minimize_btn = Gtk.Button(label="●")
        self.minimize_btn.set_relief(Gtk.ReliefStyle.NONE)
        self.minimize_btn.get_style_context().add_class('window-minimize')
        self.minimize_btn.connect('clicked', lambda b: self.window_control('minimize'))
        
        self.maximize_btn = Gtk.Button(label="●")
        self.maximize_btn.set_relief(Gtk.ReliefStyle.NONE)
        self.maximize_btn.get_style_context().add_class('window-maximize')
        self.maximize_btn.connect('clicked', lambda b: self.window_control('maximize'))
        
        controls_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        controls_box.add(self.close_btn)
        controls_box.add(self.minimize_btn)
        controls_box.add(self.maximize_btn)
        
        self.title_label = Gtk.Label(label="No Active Window")
        self.title_label.set_margin_start(10)
        
        center_box.add(controls_box)
        center_box.add(self.title_label)
        self.pack_start(center_box, True, True, 0)

        # Right: Status Icons
        right_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        right_box.set_halign(Gtk.Align.END)
        
        self.volume_label = Gtk.Label(label="🔊 --%")
        self.network_label = Gtk.Label(label="📶 --")
        self.battery_label = Gtk.Label(label="🔋 --%")
        self.ram_label = Gtk.Label(label="💾 --%")
        self.cpu_label = Gtk.Label(label="💻 --%")
        self.clock_label = Gtk.Label(label="🕐 --:--")

        right_box.add(self.cpu_label)
        right_box.add(self.ram_label)
        right_box.add(self.battery_label)
        right_box.add(self.network_label)
        right_box.add(self.volume_label)
        right_box.add(self.clock_label)
        self.pack_end(right_box, False, False, 10)

        # Periodic Updates
        GLib.timeout_add_seconds(1, self.update_status)
        GLib.timeout_add_seconds(2, self.update_title)
        GLib.timeout_add_seconds(2, self.update_workspaces)

    def update_workspaces(self):
        """Update workspace buttons from hyprctl"""
        try:
            # Get active workspaces
            output = subprocess.check_output(["hyprctl", "workspaces", "-j"]).decode()
            workspaces = json.loads(output)
            
            # Get active workspace
            active_output = subprocess.check_output(["hyprctl", "activeworkspace", "-j"]).decode()
            active_ws = json.loads(active_output)
            active_id = active_ws.get('id', 1)
            
            # Clear existing buttons
            for child in self.workspaces_box.get_children():
                self.workspaces_box.remove(child)
            
            # Create buttons for each workspace
            workspace_ids = sorted([ws['id'] for ws in workspaces])
            for ws_id in workspace_ids:
                btn = Gtk.Button(label=str(ws_id))
                btn.set_relief(Gtk.ReliefStyle.NONE)
                btn.get_style_context().add_class('workspace-btn')
                if ws_id == active_id:
                    btn.get_style_context().add_class('workspace-active')
                btn.connect('clicked', lambda b, wid=ws_id: self.switch_workspace(wid))
                self.workspaces_box.add(btn)
            
            self.workspaces_box.show_all()
        except Exception as e:
            pass
        return True

    def switch_workspace(self, workspace_id):
        """Switch to a workspace"""
        try:
            subprocess.run(["hyprctl", "dispatch", "workspace", str(workspace_id)])
        except Exception:
            pass

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
            vol_icon = "🔊" if vol > 0 else "🔇"
            self.volume_label.set_markup(f"<span font_desc='14'>{vol_icon} {vol}%</span>")
        except Exception:
            self.volume_label.set_markup("<span font_desc='14'>🔊 Error</span>")

        return True

        return True