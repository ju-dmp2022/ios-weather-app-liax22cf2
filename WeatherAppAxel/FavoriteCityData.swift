import Foundation
import SwiftData

@Model
class FavoriteCity: ObservableObject {
    @Attribute(.unique) var name: String
    var latitude: Double
    var longitude: Double

    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
