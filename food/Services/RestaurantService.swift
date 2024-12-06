import Foundation
import CoreLocation

class RestaurantService {
    static let shared = RestaurantService()
    
    private init() {}
    
    func fetchNearbyRestaurants(location: CLLocation) async throws -> [Restaurant] {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒延迟
        
        // 从本地 JSON 文件加载数据
        guard let url = Bundle.main.url(forResource: "restaurants", withExtension: "json") else {
            throw NSError(domain: "RestaurantService", code: -1, userInfo: [NSLocalizedDescriptionKey: "restaurants.json not found"])
        }
        
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(RestaurantsResponse.self, from: data)
        
        // 根据距离排序
        return response.restaurants.sorted { restaurant1, restaurant2 in
            let location1 = CLLocation(latitude: restaurant1.latitude, longitude: restaurant1.longitude)
            let location2 = CLLocation(latitude: restaurant2.latitude, longitude: restaurant2.longitude)
            
            return location1.distance(from: location) < location2.distance(from: location)
        }
    }
}
