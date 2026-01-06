import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, GtkLayerShell, GLib, Gdk
import os
import json
import signal
import sys

from widgets.weather import WeatherWidget
from widgets.clock import ClockWidget
from widgets.calendar import CalendarWidget
from widgets.cpu_ram import CpuRamWidget
from widgets.dock import DockWidget
from widgets.about import AboutWidget
from widgets.control import ControlWidget
from widgets.menu_bar import MenuBarWidget

def load_settings():
    path = os.path.expanduser('~/.config/mac-hypr/settings.json')
    if os.path.exists(path):
        with open(path, 'r') as f:
            return json.load(f)
    return {}

# Global variables for signal handling
control_window = None
control_window_visible = False

def toggle_control_center():
    global control_window_visible
    if control_window and control_window_visible:
        control_window.hide()
        control_window_visible = False
    elif control_window:
        control_window.show_all()
        control_window_visible = True

def signal_handler(signum, frame):
    if signum == signal.SIGUSR1:
        toggle_control_center()

# Set up signal handler - will be called after control_window is initialized
# signal.signal(signal.SIGUSR1, signal_handler)

def main():
    global control_window, control_window_visible

    # Main overlay window for widgets
    window = Gtk.Window()
    GtkLayerShell.init_for_window(window)
    GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
    GtkLayerShell.set_namespace(window, 'mac-hypr-overlay')

    # Box for top-right widgets (clock, weather, etc.)
    top_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
    top_box.set_halign(Gtk.Align.END)
    top_box.set_valign(Gtk.Align.START)
    top_box.set_margin_top(10)
    top_box.set_margin_right(10)

    # Add widgets
    clock = ClockWidget()
    top_box.add(clock)

    weather = WeatherWidget(settings)
    top_box.add(weather)

    cpu_ram = CpuRamWidget()
    top_box.add(cpu_ram)

    calendar = CalendarWidget()
    top_box.add(calendar)  # Toggle visibility as needed

    about = AboutWidget()
    # About can be a button-triggered dialog; for now, add to top
    top_box.add(about)

    window.add(top_box)
    window.show_all()

    # Control Center Window (initially hidden)
    control_window = Gtk.Window()
    GtkLayerShell.init_for_window(control_window)
    GtkLayerShell.set_layer(control_window, GtkLayerShell.Layer.OVERLAY)
    GtkLayerShell.set_namespace(control_window, 'mac-control-center')
    GtkLayerShell.set_anchor(control_window, GtkLayerShell.Edge.TOP, True)
    GtkLayerShell.set_anchor(control_window, GtkLayerShell.Edge.RIGHT, True)
    GtkLayerShell.set_margin(control_window, GtkLayerShell.Edge.TOP, 30)
    GtkLayerShell.set_margin(control_window, GtkLayerShell.Edge.RIGHT, 10)

    control = ControlWidget()
    control_window.add(control)
    # Don't show initially - will be toggled

    # Set up signal handler now that control_window is initialized
    signal.signal(signal.SIGUSR1, signal_handler)

    # Separate dock window
    dock_window = Gtk.Window()
    GtkLayerShell.init_for_window(dock_window)
    GtkLayerShell.set_layer(dock_window, GtkLayerShell.Layer.BOTTOM)
    GtkLayerShell.set_namespace(dock_window, 'mac-hypr-dock')
    GtkLayerShell.set_anchor(dock_window, GtkLayerShell.Edge.BOTTOM, True)
    GtkLayerShell.set_margin(dock_window, GtkLayerShell.Edge.BOTTOM, 10)

    dock = DockWidget()
    dock_window.add(dock)
    dock_window.show_all()
    
    # Menu Bar Window
    menu_bar_window = Gtk.Window()
    GtkLayerShell.init_for_window(menu_bar_window)
    GtkLayerShell.set_namespace(menu_bar_window, 'mac-menu-bar')
    GtkLayerShell.set_layer(menu_bar_window, GtkLayerShell.Layer.TOP)
    GtkLayerShell.set_anchor(menu_bar_window, GtkLayerShell.Edge.TOP, True)
    GtkLayerShell.set_anchor(menu_bar_window, GtkLayerShell.Edge.LEFT, True)
    GtkLayerShell.set_anchor(menu_bar_window, GtkLayerShell.Edge.RIGHT, True)
    GtkLayerShell.set_margin(menu_bar_window, GtkLayerShell.Edge.TOP, 0)
    
    menu_bar = MenuBarWidget()
    menu_bar_window.add(menu_bar)
    menu_bar_window.show_all()

    # Apply CSS
    css_provider = Gtk.CssProvider()
    css_provider.load_from_path(os.path.expanduser('~/.config/mac-hypr/styles/main.css'))
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(),
        css_provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    Gtk.main()

if __name__ == "__main__":
    main()