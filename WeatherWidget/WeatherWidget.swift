import WidgetKit
import SwiftUI

struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let weatherCode: Int
}

struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), temperature: 0.0, weatherCode: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(date: Date(), temperature: 0.0, weatherCode: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        Task {
            let weatherData = await fetchWeatherData()
            let entry: WeatherEntry
            if let weatherData = weatherData {
                entry = WeatherEntry(date: Date(), temperature: weatherData.currentWeather.temperature, weatherCode: weatherData.currentWeather.weathercode)
            } else {
                entry = WeatherEntry(date: Date(), temperature: 0.0, weatherCode: 0)
            }
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

    private func fetchWeatherData() async -> WeatherData? {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=Europe%2FBerlin"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            return weatherData
        } catch {
            print("Error fetching weather data: \(error)")
            return nil
        }
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

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: WeatherEntry(date: Date(), temperature: 23.5, weatherCode: 2))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
