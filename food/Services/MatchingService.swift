import Foundation
import CoreLocation

class MatchingService {
    static let shared = MatchingService()
    
    private init() {}
    
    func findMatches(at restaurant: Restaurant, time: Date, currentLocation: CLLocation) async throws -> [User] {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒延迟
        
        // 从本地 JSON 文件加载用户数据
        guard let url = Bundle.main.url(forResource: "users", withExtension: "json") else {
            throw NSError(domain: "MatchingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "users.json not found"])
        }
        
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(MatchedUsersResponse.self, from: data)
        
        // 模拟匹配逻辑：
        // 1. 按距离筛选（距离餐厅1公里以内）
        // 2. 最多返回3个用户
        let restaurantLocation = CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)
        
        let nearbyUsers = response.users.filter { user in
            let userLocation = CLLocation(latitude: user.latitude, longitude: user.longitude)
            let distance = userLocation.distance(from: restaurantLocation)
            return distance <= 1000 // 1公里以内
        }
        
        // 按距离排序
        let sortedUsers = nearbyUsers.sorted { user1, user2 in
            let location1 = CLLocation(latitude: user1.latitude, longitude: user1.longitude)
            let location2 = CLLocation(latitude: user2.latitude, longitude: user2.longitude)
            return location1.distance(from: restaurantLocation) < location2.distance(from: restaurantLocation)
        }
        
        // 返回前3个用户
        return Array(sortedUsers.prefix(3))
    }
    
    func sendMatchRequest(to userId: String) async throws -> Bool {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 模拟成功率 80%
        return Double.random(in: 0...1) < 0.8
    }
}
