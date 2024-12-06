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
        // 添加示例数据
        self.restaurants = [
            Restaurant(
                id: "1",
                name: "科技园餐厅",
                type: .chinese,
                address: "科技园路1号",
                latitude: 31.2304,
                longitude: 121.4737,
                rating: 4.5,
                priceLevel: "¥¥",
                openTime: "10:00-21:30",
                imageUrl: nil
            ),
            Restaurant(
                id: "2",
                name: "日式料理",
                type: .japanese,
                address: "科技园路2号",
                latitude: 31.2305,
                longitude: 121.4738,
                rating: 4.8,
                priceLevel: "¥¥¥",
                openTime: "11:00-22:00",
                imageUrl: nil
            ),
            Restaurant(
                id: "3",
                name: "咖啡馆",
                type: .coffee,
                address: "科技园路3号",
                latitude: 31.2306,
                longitude: 121.4739,
                rating: 4.3,
                priceLevel: "¥¥",
                openTime: "08:00-20:00",
                imageUrl: nil
            )
        ]
    }
    
    func updateLocationService(_ newLocationService: LocationService) {
        self.locationService = newLocationService
    }
    
    func refreshRestaurants() async {
        // 暂时不刷新，使用示例数据
        return
        
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
