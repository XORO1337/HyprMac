import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import requests
import json
import os

class WeatherWidget(Gtk.Box):
    def __init__(self, settings):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.mode = settings.get('weather_mode', 'current')
        self.location = self.get_location(settings)
        self.label = Gtk.Label()
        self.add(self.label)
        self.update()
        GLib.timeout_add_seconds(1800, self.update)  # Update every 30 min

    def get_location(self, settings):
        coords = settings.get('coords')
        if coords:
            return coords
        city = settings.get('city', '')
        if city:
            return self.geocode_city(city)
        try:
            resp = requests.get('https://ipapi.co/json/').json()
            return f"{resp['latitude']},{resp['longitude']}"
        except Exception:
            return "37.7749,-122.4194"  # Default San Francisco

    def geocode_city(self, city):
        url = f"https://geocoding-api.open-meteo.com/v1/search?name={city}&count=1&language=en&format=json"
        try:
            resp = requests.get(url).json()
            hit = resp.get('results', [{}])[0]
            return f"{hit.get('latitude', 0)},{hit.get('longitude', 0)}"
        except Exception:
            return "0,0"

    def fetch_weather(self):
        lat, lon = self.location.split(',')
        url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,weather_code,precipitation,wind_speed_10m,wind_direction_10m&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_sum&timezone=auto&forecast_days=7"
        return requests.get(url).json()

    def update(self):
        try:
            data = self.fetch_weather()
            current = data['current']
            daily = data['daily']
            temp = current['temperature_2m']
            code = current['weather_code']
            icon = self.get_icon(code)
            text = f"{icon} {temp}°C"

            if self.mode == "minimal":
                high = daily['temperature_2m_max'][0]
                low = daily['temperature_2m_min'][0]
                precip = current['precipitation']
                wind = current['wind_speed_10m']
                dir = self.wind_dir(current['wind_direction_10m'])
                text += f"\nH: {high}° L: {low}° Precip: {precip}mm Wind: {wind}km/h {dir}"

            elif self.mode == "detailed":
                text += "\n7-Day Forecast:"
                for i in range(7):
                    day = daily['time'][i]
                    h = daily['temperature_2m_max'][i]
                    l = daily['temperature_2m_min'][i]
                    c = daily['weather_code'][i]
                    p = daily['precipitation_sum'][i]
                    icon_d = self.get_icon(c)
                    text += f"\n{day}: {icon_d} H:{h}° L:{l}° Precip:{p}mm"

            self.label.set_markup(f"<span font='SF Pro 12'>{text}</span>")
        except Exception as e:
            self.label.set_text("Weather Error")
        return True

    def get_icon(self, code):
        # macOS-like icons using Unicode (install Font Awesome for more)
        mapping = {
            0: "☀️",  # Clear
            1: "🌤️", 2: "⛅", 3: "☁️",  # Cloudy
            45: "🌫️", 48: "🌫️",  # Fog
            51: "🌧️", 53: "🌧️", 55: "🌧️",  # Drizzle
            61: "🌧️", 63: "🌧️", 65: "🌧️",  # Rain
            71: "❄️", 73: "❄️", 75: "❄️",  # Snow
            80: "🌧️", 81: "🌧️", 82: "🌧️",  # Showers
            95: "⛈️",  # Thunderstorm
            96: "⛈️", 99: "⛈️"   # Thunder with hail
        }
        return mapping.get(code, "❓")

    def wind_dir(self, deg):
        dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW']
        return dirs[int((deg + 11.25) / 22.5) % 16]