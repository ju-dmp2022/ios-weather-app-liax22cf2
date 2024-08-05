import SwiftUI

struct MainView: View {
    @StateObject var weatherManager = WeatherManager()

    var body: some View {
        NavigationStack {
            VStack {
                if let weatherData = weatherManager.weatherData {
                    CurrentWeatherView(currentWeather: weatherData.currentWeather)
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
            Task {
                await weatherManager.startUpdatingLocation()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
