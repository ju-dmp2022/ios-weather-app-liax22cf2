import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query private var favoriteCities: [FavoriteCity]
    @Environment(\.modelContext) private var modelContext  // SwiftData context

    var body: some View {
        VStack {
            if favoriteCities.isEmpty {
                Text("No favorite cities saved")
                    .font(.headline)
                    .padding()
            } else {
                List {
                    ForEach(favoriteCities) { city in
                        NavigationLink(destination: SearchView(cityName: city.name, latitude: city.latitude, longitude: city.longitude, isFromFavorites: true)) {
                            VStack(alignment: .leading) {
                                Text(city.name)
                                    .font(.headline)
                                Text("Latitude: \(city.latitude), Longitude: \(city.longitude)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .onDelete(perform: deleteFavoriteCity)
                }
            }
        }
        .navigationTitle("Favorite Cities")
    }

 
    private func deleteFavoriteCity(at offsets: IndexSet) {
        for index in offsets {
            let cityToDelete = favoriteCities[index]
            modelContext.delete(cityToDelete)  //Remove from SwiftData context
        }

        do {
            try modelContext.save()  //Save the context after deletion
            print("Favorite city deleted")
        } catch {
            print("Failed to delete city: \(error.localizedDescription)")
        }
    }
}
