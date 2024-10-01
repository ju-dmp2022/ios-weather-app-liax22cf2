//test
import Foundation
import CoreLocation
import Observation

@Observable
class WeatherManager: NSObject, CLLocationManagerDelegate {
    var weatherData: WeatherData?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        checkLocationAuthorizationStatus()
    }

    func checkLocationAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location services are restricted or denied.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorizationStatus()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("Location updated: \(location.coordinate)")

        // Spara platsdata till UserDefaults med App Group
        let defaults = UserDefaults(suiteName: "group.com.ju.weatherapp")
        defaults?.set(location.coordinate.latitude, forKey: "latitude")
        defaults?.set(location.coordinate.longitude, forKey: "longitude")

        
        print("Saved latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")

        Task {
            await self.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }

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
}
