import Foundation
import CoreLocation

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func updateLocationService(_ newLocationService: LocationService) {
        self.locationService = newLocationService
        Task {
            await refreshRestaurants()
        }
    }
    
    func refreshRestaurants() async {
        guard let location = locationService.currentLocation else {
            print("No location available")
            error = "无法获取位置信息"
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            print("Fetching restaurants for location: \(location)")
            let restaurants = try await RestaurantService.shared.fetchNearbyRestaurants(location: location)
            self.restaurants = restaurants
            print("Updated restaurants: \(restaurants.count)")
        } catch {
            print("Failed to fetch restaurants: \(error)")
            self.error = "获取餐厅信息失败：\(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
