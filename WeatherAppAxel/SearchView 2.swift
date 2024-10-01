import SwiftUI
import MapKit

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var selectedWeatherData: WeatherData?
    var weatherManager = WeatherManager()

    var body: some View {
        VStack {
            TextField("Search for a city", text: $searchText, onCommit: {
                performSearch()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            if isSearching {
                Text("Searching...")
                    .font(.headline)
                    .padding()
            }

            if !searchResults.isEmpty {
                List(searchResults, id: \.self) { mapItem in
                    Button(action: {
                        selectLocation(mapItem)
                    }) {
                        Text(mapItem.name ?? "Unknown location")
                    }
                }
            }



            if let weatherData = selectedWeatherData {
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
            }
        }
        .navigationTitle("Search for a City")
    }

    
    //Perform search using MapKit
    private func performSearch() {
        guard !searchText.isEmpty else { return }

        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                self.searchResults = response.mapItems
            }
            isSearching = false
        }
    }

    // Handle the selection of a location from search results
    private func selectLocation(_ mapItem: MKMapItem) {
        if let coordinate = mapItem.placemark.location?.coordinate {
            Task {
                await weatherManager.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.selectedWeatherData = weatherManager.weatherData
            }
        }
        searchText = mapItem.name ?? ""
        isSearching = false
    }
}
