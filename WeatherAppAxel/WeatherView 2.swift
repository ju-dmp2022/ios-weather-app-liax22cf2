import SwiftUI
import MapKit  // <-- Add this import to use MapKit

struct WeatherView: View {
    @State private var searchText = ""  // State to hold search input
    @State private var searchResults: [MKMapItem] = []  // Holds search results
    @State private var isSearching = false  // Indicates if a search is in progress
    var weatherManager = WeatherManager()

    var body: some View {
        NavigationStack {
            VStack {
                // Add a search bar at the top
                TextField("Search for a city", text: $searchText, onCommit: {
                    performSearch()  // When the user presses return, perform the search
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())  // Make the search bar rounded
                .padding()  // Add padding around the search bar
                
                // Show the search results in a List when searching
                if isSearching {
                    List(searchResults, id: \.self) { mapItem in
                        Button(action: {
                            selectLocation(mapItem)  // Handle city selection
                        }) {
                            Text(mapItem.name ?? "Unknown location")  // Display the city name
                        }
                    }
                } else {
                    // Your existing weather UI goes here
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
            }
            .navigationTitle("Weather")
        }
        .onAppear {
            weatherManager.checkLocationAuthorizationStatus()
        }
    }

    // Step 2: Define performSearch function to search for cities using MapKit
    private func performSearch() {
        guard !searchText.isEmpty else {
            print("Search text is empty")
            return
        }
        
        print("Performing search for: \(searchText)")
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText  // Search for what the user typed
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let error = error {
                print("Error occurred during search: \(error.localizedDescription)")
                isSearching = false
                return
            }
            
            guard let response = response else {
                print("No search response")
                isSearching = false
                return
            }
            
            print("Search results found: \(response.mapItems.count)")
            self.searchResults = response.mapItems  // Update the results
            isSearching = false
        }
    }


    // Step 3: Handle selecting a city from the search results
    private func selectLocation(_ mapItem: MKMapItem) {
        if let coordinate = mapItem.placemark.location?.coordinate {
            Task {
                await weatherManager.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }
        searchText = mapItem.name ?? ""  // Update the search bar with the selected city's name
        isSearching = false  // Close the search results
    }

}
