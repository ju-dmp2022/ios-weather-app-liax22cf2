import SwiftUI
import MapKit
import SwiftData

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var selectedWeatherData: WeatherData?
    @State private var selectedCity: MKMapItem?

    var weatherManager = WeatherManager()
    var cityName: String?
    var latitude: Double?
    var longitude: Double?
    var isFromFavorites: Bool = false
    //default false förutom om man kommer från Favorites

    @Query private var favoriteCities: [FavoriteCity]
    @Environment(\.modelContext) private var modelContext  //SwiftData context

    var body: some View {
        VStack {
            //defauly synligt om man inte kommer från Favorites
            if !isFromFavorites {
                TextField("Search for a city", text: $searchText, onCommit: {
                    performSearch()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }


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

            //visa väder för en vald city
            if let weatherData = selectedWeatherData {
                VStack {
                    Text("Current Temperature")
                        .font(.headline)
                    Text("\(Int(weatherData.currentWeather.temperature))°C")
                        .font(.largeTitle)
                    Text(weatherDescription(for: weatherData.currentWeather.weathercode))
                        .font(.subheadline)
                        .padding()
                    
                    //När vi visar add to favorites button
                    if !isFromFavorites && !isCityAlreadyFavorite(cityName: selectedCity?.name ?? "", latitude: selectedCity?.placemark.coordinate.latitude ?? 0, longitude: selectedCity?.placemark.coordinate.longitude ?? 0) {
                        Button(action: {
                            if let city = selectedCity {
                                saveToFavorites(city: city)
                            }
                        }) {
                            Text("Save to Favorites")
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                        }
                    } else if isFromFavorites {
                        Text("This city is already in your favorites")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            
            Spacer()
            
 

        }
        .onAppear {
            // Pre-fill and fetch weather data if from favorites view
            if isFromFavorites, let lat = latitude, let lon = longitude {
                Task {
                    await weatherManager.fetchWeather(latitude: lat, longitude: lon)
                    self.selectedWeatherData = weatherManager.weatherData
                    self.selectedCity = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)))
                    self.isSearching = false
                }
            }
        }
        .navigationTitle("Search for a City")
    }

      
    
    

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

    
    private func selectLocation(_ mapItem: MKMapItem) {
        if let coordinate = mapItem.placemark.location?.coordinate {
            Task {
                await weatherManager.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.selectedWeatherData = weatherManager.weatherData
                self.selectedCity = mapItem  //Store den valda staden
            }
        }
        searchText = mapItem.name ?? ""
        isSearching = false
    }

    private func saveToFavorites(city: MKMapItem) {
        guard let coordinate = city.placemark.location?.coordinate else { return }

        let favoriteCity = FavoriteCity(name: city.name ?? "Unknown", latitude: coordinate.latitude, longitude: coordinate.longitude)
        modelContext.insert(favoriteCity)

        do {
            try modelContext.save()
            print("City saved to favorites")
        } catch {
            print("Failed to save city: \(error.localizedDescription)")
        }
    }

    private func isCityAlreadyFavorite(cityName: String, latitude: Double, longitude: Double) -> Bool {
        return favoriteCities.contains { $0.name == cityName && $0.latitude == latitude && $0.longitude == longitude }
        //$0 = current city in the array favoriteCities
    }
}
