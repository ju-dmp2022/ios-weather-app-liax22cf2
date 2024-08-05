import SwiftUI

struct CurrentWeatherView: View {
    let currentWeather: WeatherData.CurrentWeather

    var body: some View {
        VStack {
            Text("Current Temperature")
                .font(.headline)
            Text("\(Int(currentWeather.temperature))°C")
                .font(.largeTitle)
            Text(weatherDescription(for: currentWeather.weathercode))
                .font(.subheadline)
                .padding()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
        .padding()
    }
}

struct CurrentWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentWeatherView(currentWeather: WeatherData.CurrentWeather(temperature: 22.5, weathercode: 1))
    }
}
