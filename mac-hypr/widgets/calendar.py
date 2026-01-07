import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class CalendarWidget(Gtk.Calendar):
    def __init__(self):
        super().__init__()
        self.set_display_options(Gtk.CalendarDisplayOptions.SHOW_HEADING | Gtk.CalendarDisplayOptions.SHOW_DAY_NAMES)