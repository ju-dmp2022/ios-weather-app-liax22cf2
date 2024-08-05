import Foundation
import CoreLocation

class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weatherData: WeatherData?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    @MainActor
    func startUpdatingLocation() async {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            print("Location updates started")
        } else {
            print("Location services are not enabled")
        }
    }

    @MainActor
    func fetchWeather(latitude: Double, longitude: Double) async {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=Europe%2FBerlin"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            print("Weather data decoded successfully")
            self.weatherData = weatherData
        } catch {
            print("Error fetching weather data: \(error)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("Location updated: \(location.coordinate)")
        Task {
            await self.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}
