// Weather Widget
// Weather display with OpenWeatherMap integration

import { Widget, Service } from '../imports.js';
import { exec, execAsync } from '../utils.js';

// Weather service using OpenWeatherMap API
class WeatherService extends Service {
    static {
        Service.register(this, {
            'weather-updated': ['string'],
        });
    }
    
    constructor() {
        super();
        this._weather = {
            temperature: 0,
            condition: 'Unknown',
            humidity: 0,
            windSpeed: 0,
            icon: 'weather-none-available',
            location: 'Unknown',
            feelsLike: 0,
            pressure: 0,
            visibility: 0,
            uvIndex: 0,
        };
        
        this._apiKey = this._getApiKey();
        this._location = this._getLocation();
        this._updateInterval = 30 * 60 * 1000; // 30 minutes
        
        this._startPolling();
    }
    
    get weather() {
        return this._weather;
    }
    
    _getApiKey() {
        try {
            const config = JSON.parse(exec('cat ~/.config/weather/config.json'));
            return config.apiKey || '';
        } catch (e) {
            return '';
        }
    }
    
    _getLocation() {
        try {
            const config = JSON.parse(exec('cat ~/.config/weather/config.json'));
            return config.location || 'auto';
        } catch (e) {
            return 'auto';
        }
    }
    
    async _getCurrentLocation() {
        try {
            if (this._location === 'auto') {
                const geoData = await execAsync('curl -s https://ipapi.co/json/');
                const geo = JSON.parse(geoData);
                return `${geo.city},${geo.country}`;
            }
            return this._location;
        } catch (e) {
            return 'London,UK'; // Default fallback
        }
    }
    
    async _fetchWeather() {
        if (!this._apiKey) {
            console.error('Weather API key not configured');
            return;
        }
        
        try {
            const location = await this._getCurrentLocation();
            const response = await execAsync(
                `curl -s "https://api.openweathermap.org/data/2.5/weather?q=${location}&appid=${this._apiKey}&units=metric"`
            );
            
            const data = JSON.parse(response);
            
            this._weather = {
                temperature: Math.round(data.main.temp),
                condition: data.weather[0].main,
                humidity: data.main.humidity,
                windSpeed: data.wind.speed,
                icon: this._getWeatherIcon(data.weather[0].id),
                location: data.name,
                feelsLike: Math.round(data.main.feels_like),
                pressure: data.main.pressure,
                visibility: data.visibility / 1000, // Convert to km
                uvIndex: 0, // Requires separate API call
            };
            
            this.emit('weather-updated', JSON.stringify(this._weather));
        } catch (e) {
            console.error('Failed to fetch weather:', e);
        }
    }
    
    _getWeatherIcon(weatherId) {
        // Map OpenWeatherMap condition codes to icon names
        const iconMap = {
            // Thunderstorm
            200: 'weather-storm', 201: 'weather-storm', 202: 'weather-storm',
            210: 'weather-lightning', 211: 'weather-lightning', 212: 'weather-lightning',
            221: 'weather-lightning', 230: 'weather-storm', 231: 'weather-storm', 232: 'weather-storm',
            
            // Drizzle
            300: 'weather-showers', 301: 'weather-showers', 302: 'weather-showers',
            310: 'weather-showers', 311: 'weather-showers', 312: 'weather-showers',
            313: 'weather-showers', 314: 'weather-showers', 321: 'weather-showers',
            
            // Rain
            500: 'weather-showers', 501: 'weather-showers', 502: 'weather-showers',
            503: 'weather-showers', 504: 'weather-showers', 511: 'weather-snow-rain',
            520: 'weather-showers-scattered', 521: 'weather-showers-scattered',
            522: 'weather-showers-scattered', 531: 'weather-showers-scattered',
            
            // Snow
            600: 'weather-snow', 601: 'weather-snow', 602: 'weather-snow',
            611: 'weather-snow-rain', 612: 'weather-snow-rain', 613: 'weather-snow-rain',
            615: 'weather-snow-rain', 616: 'weather-snow-rain', 620: 'weather-snow',
            621: 'weather-snow', 622: 'weather-snow',
            
            // Atmosphere
            701: 'weather-fog', 711: 'weather-fog', 721: 'weather-fog',
            731: 'weather-fog', 741: 'weather-fog', 751: 'weather-fog',
            761: 'weather-fog', 762: 'weather-fog', 771: 'weather-fog',
            781: 'weather-fog',
            
            // Clear
            800: 'weather-clear',
            
            // Clouds
            801: 'weather-few-clouds', 802: 'weather-overcast',
            803: 'weather-overcast', 804: 'weather-overcast',
        };
        
        return iconMap[weatherId] || 'weather-none-available';
    }
    
    _startPolling() {
        this._fetchWeather();
        setInterval(() => this._fetchWeather(), this._updateInterval);
    }
}

const weatherService = new WeatherService();

export default () => {
    // Weather widget for desktop
    const WeatherWidget = () => Widget.Window({
        name: 'weather-widget',
        anchor: ['top', 'right'],
        layer: 'bottom',
        margins: [60, 20, 0, 0],
        visible: true,
        child: Widget.Box({
            className: 'weather-widget',
            vertical: true,
            css: `
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 16px;
                border: 1px solid rgba(0, 0, 0, 0.1);
                padding: 16px;
                min-width: 200px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            `,
            children: [
                // Header with location
                Widget.Box({
                    children: [
                        Widget.Icon({
                            icon: weatherService.weather.icon,
                            size: 48,
                            css: 'margin-right: 12px;'
                        }),
                        Widget.Box({
                            vertical: true,
                            children: [
                                Widget.Label({
                                    label: weatherService.weather.temperature + '°C',
                                    css: 'font-size: 32px; font-weight: 300;'
                                }),
                                Widget.Label({
                                    label: weatherService.weather.location,
                                    css: 'font-size: 14px; opacity: 0.7;'
                                })
                            ]
                        })
                    ]
                }),
                
                // Weather condition
                Widget.Label({
                    label: weatherService.weather.condition,
                    css: 'font-size: 16px; margin-top: 8px;'
                }),
                
                // Additional weather details
                Widget.Box({
                    vertical: true,
                    spacing: 4,
                    css: 'margin-top: 12px;',
                    children: [
                        Widget.Label({
                            label: `Feels like: ${weatherService.weather.feelsLike}°C`,
                            css: 'font-size: 12px; opacity: 0.8;'
                        }),
                        Widget.Label({
                            label: `Humidity: ${weatherService.weather.humidity}%`,
                            css: 'font-size: 12px; opacity: 0.8;'
                        }),
                        Widget.Label({
                            label: `Wind: ${weatherService.weather.windSpeed} m/s`,
                            css: 'font-size: 12px; opacity: 0.8;'
                        }),
                        Widget.Label({
                            label: `Pressure: ${weatherService.weather.pressure} hPa`,
                            css: 'font-size: 12px; opacity: 0.8;'
                        })
                    ]
                })
            ],
        }),
    });
    
    // Update weather display when data changes
    weatherService.connect('weather-updated', () => {
        // Update widget content here
    });
    
    return WeatherWidget();
};

// Export weather service for other widgets
export { weatherService };