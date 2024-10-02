import SwiftUI

struct WeatherView: View {
    var weatherManager = WeatherManager()

    var body: some View {
        NavigationStack {
            VStack {
                

                //Visa väderdata om tillgängligt
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
                            .foregroundColor(.green)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))
                    }
                } else {
                    Text("Loading weather data...")
                        .font(.headline)
                        .padding()
                }


                NavigationLink(destination: SearchView()) {
                    Text("Search for a City")
                        .foregroundColor(.blue)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }
                .padding()


                NavigationLink(destination: FavoritesView()) {
                    Text("Favorite Cities")
                        .foregroundColor(.yellow)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 2))
                }
                .padding()
                
                
                
                
                
                //Visa users plats i koordinater
                if let latitude = weatherManager.userLatitude, let longitude = weatherManager.userLongitude {
                    Text("Your Location:")
                        .font(.headline)
                    Text("Latitude: \(latitude), Longitude: \(longitude)")
                        .font(.subheadline)
                        .padding()
                } else {
                    Text("Fetching your location...")
                        .font(.subheadline)
                        .padding()
                }
            }
            .navigationTitle("Weather")
        }
        .onAppear {
            weatherManager.checkLocationAuthorizationStatus()
        }
    }
}




