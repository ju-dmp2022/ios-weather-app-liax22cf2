import WidgetKit
import SwiftUI

struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let weatherCode: Int
}

struct WeatherProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(), temperature: 15.0, weatherCode: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(date: Date(), temperature: 15.0, weatherCode: 1)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        Task {
            let defaults = UserDefaults(suiteName: "group.com.ju.weatherapp")
            let latitude = defaults?.double(forKey: "latitude") ?? 0.0
            let longitude = defaults?.double(forKey: "longitude") ?? 0.0

            print("Fetched latitude: \(latitude), longitude: \(longitude)")

            guard latitude != 0.0 && longitude != 0.0 else {
                print("Invalid latitude or longitude")
                let entry = WeatherEntry(date: Date(), temperature: 0.0, weatherCode: 0)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                return
            }

            let weatherData = await fetchWeatherData(latitude: latitude, longitude: longitude)
            
            let entry = WeatherEntry(date: Date(), temperature: weatherData.temperature, weatherCode: weatherData.weatherCode)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

    private func fetchWeatherData(latitude: Double, longitude: Double) async -> (temperature: Double, weatherCode: Int) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=Europe%2FBerlin"
        guard let url = URL(string: urlString) else { return (0.0, 0) }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            
            print("Fetched weather data: \(weatherData.currentWeather.temperature)°C")
            
            return (weatherData.currentWeather.temperature, weatherData.currentWeather.weathercode)
        } catch {
            print("Error fetching weather data: \(error)")
            return (0.0, 0)
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather Widget")
        .description("Displays the current weather.")
    }
}

struct WeatherWidgetEntryView: View {
    var entry: WeatherProvider.Entry

    var body: some View {
        VStack {
            Text("Current Temperature")
                .font(.headline)
            Text("\(Int(entry.temperature))°C")
                .font(.largeTitle)
            Text(weatherDescription(for: entry.weatherCode))
                .font(.subheadline)
        }
        .padding()
        .onAppear {
            print("Rendering widget with temperature: \(entry.temperature)°C")
        }
    }
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: WeatherEntry(date: Date(), temperature: 23.5, weatherCode: 2))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
