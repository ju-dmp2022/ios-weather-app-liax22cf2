import SwiftUI
import Foundation

struct WeatherView: View {
    var weatherManager = WeatherManager()

    var body: some View {
        NavigationStack {
            VStack {
                if let weatherData = weatherManager.weatherData {
                    VStack {
                        Text("Current Temperature")
                            .font(.headline)
                        Text("\(Int(weatherData.currentWeather.temperature))°C")
                            .font(.largeTitle)
                        Text(weatherDescription(for: weatherData.currentWeather.weathercode))
                            .font(.subheadline)
                            .padding()
                    }
                    .padding()
                    NavigationLink(destination: ForecastView(dailyWeather: weatherData.daily)) {
                        Text("7-Day Forecast")
                            .foregroundColor(.blue)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                    }
                } else {
                    Text("Loading...")
                        .font(.headline)
                        .padding()
                }
            }
            .navigationTitle("Weather")
        }
        .onAppear {
            weatherManager.checkLocationAuthorizationStatus()  // Anropa rätt metod
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
