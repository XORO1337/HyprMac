import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import psutil

class CpuRamWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.cpu_label = Gtk.Label()
        self.ram_label = Gtk.Label()
        self.add(self.cpu_label)
        self.add(self.ram_label)
        self.update()
        GLib.timeout_add_seconds(2, self.update)

    def update(self):
        cpu = psutil.cpu_percent()
        ram = psutil.virtual_memory().percent
        self.cpu_label.set_markup(f"<span>CPU: {cpu}%</span>")
        self.ram_label.set_markup(f"<span>RAM: {ram}%</span>")
        return True