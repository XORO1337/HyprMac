import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
import platform
import psutil

class AboutWidget(Gtk.Button):
    def __init__(self):
        super().__init__(label="About")
        self.connect('clicked', self.show_dialog)

    def show_dialog(self, button):
        dialog = Gtk.Dialog(title="About This Computer", transient_for=None)
        dialog.set_modal(True)
        box = dialog.get_content_area()
        info = f"OS: {platform.system()} {platform.release()}\nProcessor: {platform.processor()}\nRAM: {psutil.virtual_memory().total / (1024**3):.2f} GB"
        label = Gtk.Label(label=info)
        box.add(label)
        dialog.add_button("OK", Gtk.ResponseType.OK)
        dialog.show_all()
        dialog.run()
        dialog.destroy()