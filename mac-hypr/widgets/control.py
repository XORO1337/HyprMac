from gi.repository import Gtk
import os
import subprocess

class ControlWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.set_size_request(300, -1)

        # Brightness section
        bright_frame = Gtk.Frame(label="Display")
        bright_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        bright_box.set_margin_start(10)
        bright_box.set_margin_end(10)
        bright_box.set_margin_top(5)
        bright_box.set_margin_bottom(5)

        bright_label = Gtk.Label(label="Brightness", halign=Gtk.Align.START)
        bright_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        bright_scale.set_value(self.get_current_brightness())
        bright_scale.connect('value-changed', lambda s: os.system(f'brightnessctl s {int(s.get_value())}%'))

        # Night Shift toggle
        night_shift_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        night_shift_label = Gtk.Label(label="Night Shift", halign=Gtk.Align.START)
        night_shift_switch = Gtk.Switch()
        night_shift_switch.set_active(self.is_night_shift_enabled())
        night_shift_switch.connect('notify::active', self.on_night_shift_toggled)
        night_shift_box.pack_start(night_shift_label, True, True, 0)
        night_shift_box.pack_end(night_shift_switch, False, False, 0)

        bright_box.add(bright_label)
        bright_box.add(bright_scale)
        bright_box.add(night_shift_box)
        bright_frame.add(bright_box)
        self.add(bright_frame)

        # Sound section
        sound_frame = Gtk.Frame(label="Sound")
        sound_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        sound_box.set_margin_start(10)
        sound_box.set_margin_end(10)
        sound_box.set_margin_top(5)
        sound_box.set_margin_bottom(5)

        vol_label = Gtk.Label(label="Volume", halign=Gtk.Align.START)
        vol_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        vol_scale.set_value(self.get_current_volume())
        vol_scale.connect('value-changed', lambda s: os.system(f'pactl set-sink-volume @DEFAULT_SINK@ {int(s.get_value())}%'))

        sound_box.add(vol_label)
        sound_box.add(vol_scale)
        sound_frame.add(sound_box)
        self.add(sound_frame)

        # Music controls
        music_frame = Gtk.Frame(label="Now Playing")
        music_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        music_box.set_margin_start(10)
        music_box.set_margin_end(10)
        music_box.set_margin_top(5)
        music_box.set_margin_bottom(5)

        prev_btn = Gtk.Button(label="⏮")
        prev_btn.connect('clicked', lambda b: os.system('playerctl previous'))

        play_btn = Gtk.Button(label="▶️")
        play_btn.connect('clicked', lambda b: os.system('playerctl play-pause'))

        next_btn = Gtk.Button(label="⏭")
        next_btn.connect('clicked', lambda b: os.system('playerctl next'))

        music_box.add(prev_btn)
        music_box.add(play_btn)
        music_box.add(next_btn)
        music_frame.add(music_box)
        self.add(music_frame)

        # Network section
        network_frame = Gtk.Frame(label="Network")
        network_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        network_box.set_margin_start(10)
        network_box.set_margin_end(10)
        network_box.set_margin_top(5)
        network_box.set_margin_bottom(5)

        wifi_label = Gtk.Label(label="Wi-Fi", halign=Gtk.Align.START)
        wifi_switch = Gtk.Switch()
        wifi_switch.set_active(self.is_wifi_enabled())
        wifi_switch.connect('notify::active', self.on_wifi_toggled)

        network_box.add(wifi_label)
        network_box.add(wifi_switch)

        # Bluetooth toggle
        bluetooth_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        bluetooth_label = Gtk.Label(label="Bluetooth", halign=Gtk.Align.START)
        bluetooth_switch = Gtk.Switch()
        bluetooth_switch.set_active(self.is_bluetooth_enabled())
        bluetooth_switch.connect('notify::active', self.on_bluetooth_toggled)
        bluetooth_box.pack_start(bluetooth_label, True, True, 0)
        bluetooth_box.pack_end(bluetooth_switch, False, False, 0)

        network_box.add(bluetooth_box)
        network_frame.add(network_box)
        self.add(network_frame)

        # Do Not Disturb
        dnd_frame = Gtk.Frame(label="Focus")
        dnd_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        dnd_box.set_margin_start(10)
        dnd_box.set_margin_end(10)
        dnd_box.set_margin_top(5)
        dnd_box.set_margin_bottom(5)

        dnd_label = Gtk.Label(label="Do Not Disturb", halign=Gtk.Align.START)
        dnd_switch = Gtk.Switch()
        dnd_switch.set_active(self.is_dnd_enabled())
        dnd_switch.connect('notify::active', self.on_dnd_toggled)

        dnd_box.add(dnd_label)
        dnd_box.add(dnd_switch)
        dnd_frame.add(dnd_box)
        self.add(dnd_frame)

    def get_current_brightness(self):
        try:
            output = subprocess.check_output(['brightnessctl', 'g']).decode().strip()
            max_output = subprocess.check_output(['brightnessctl', 'm']).decode().strip()
            return int(int(output) / int(max_output) * 100)
        except:
            return 50

    def get_current_volume(self):
        try:
            output = subprocess.check_output("pactl get-sink-volume @DEFAULT_SINK@", shell=True).decode()
            return int(output.split()[4].strip('%'))
        except:
            return 50

    def is_wifi_enabled(self):
        try:
            output = subprocess.check_output(['nmcli', 'radio', 'wifi']).decode().strip()
            return output == 'enabled'
        except:
            return True

    def on_wifi_toggled(self, switch, gparam):
        state = 'on' if switch.get_active() else 'off'
        os.system(f'nmcli radio wifi {state}')

    def is_dnd_enabled(self):
        try:
            output = subprocess.check_output(['swaync-client', '--get-dnd']).decode().strip()
            return output == 'true'
        except:
            return False

    def on_dnd_toggled(self, switch, gparam):
        state = 'true' if switch.get_active() else 'false'
        os.system(f'swaync-client --dnd {state}')

    def is_night_shift_enabled(self):
        try:
            # Check if gammastep or redshift is running (common blue light filters)
            output = subprocess.check_output(['pgrep', '-f', 'gammastep|redshift']).decode().strip()
            return bool(output)
        except:
            return False

    def on_night_shift_toggled(self, switch, gparam):
        if switch.get_active():
            # Enable night shift (you may need to install gammastep or redshift)
            os.system('gammastep -O 3500 2>/dev/null || redshift -O 3500 2>/dev/null || true')
        else:
            # Disable night shift
            os.system('pkill gammastep 2>/dev/null; pkill redshift 2>/dev/null; true')

    def is_bluetooth_enabled(self):
        try:
            output = subprocess.check_output(['bluetoothctl', 'show']).decode()
            return 'Powered: yes' in output
        except:
            return False

    def on_bluetooth_toggled(self, switch, gparam):
        if switch.get_active():
            os.system('bluetoothctl power on')
        else:
            os.system('bluetoothctl power off')