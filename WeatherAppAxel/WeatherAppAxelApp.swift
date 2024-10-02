import SwiftUI
import SwiftData

@main
struct WeatherAppAxelApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherView()
                .modelContainer(for: [FavoriteCity.self])
        }
    }
}

