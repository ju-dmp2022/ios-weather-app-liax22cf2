import SwiftUI

struct ForecastView: View {
    let dailyWeather: WeatherData.DailyWeather

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(0..<dailyWeather.time.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(dailyWeather.time[index])
                            .font(.headline)
                        Text("Max: \(Int(dailyWeather.temperature2mMax[index]))°C")
                        Text("Min: \(Int(dailyWeather.temperature2mMin[index]))°C")
                        Text(weatherDescription(for: dailyWeather.weatherCode[index]))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.1)))
                    .padding(4)
                }
            }
            .padding()
        }
        .navigationTitle("7-Day Forecast")
    }
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView(dailyWeather: WeatherData.DailyWeather(time: ["2024-08-01"], weatherCode: [1], temperature2mMax: [25.0], temperature2mMin: [15.0]))
    }
}
