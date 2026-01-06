from gi.repository import Gtk, GLib
from datetime import datetime

class ClockWidget(Gtk.Label):
    def __init__(self):
        super().__init__()
        self.update()
        GLib.timeout_add_seconds(1, self.update)

    def update(self):
        self.set_markup(f"<span font='SF Pro 14'>{datetime.now().strftime('%I:%M %p')}</span>")
        return True