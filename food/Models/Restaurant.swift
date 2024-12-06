import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let type: RestaurantType
    let address: String
    let latitude: Double
    let longitude: Double
    let rating: Double
    let priceLevel: String
    let openTime: String
    let imageUrl: String?  // 添加可选的图片URL字段
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum RestaurantType: String, Codable {
        case fastFood = "fastFood"
        case japanese = "japanese"
        case coffee = "coffee"
        case chinese = "chinese"
        case western = "western"
        
        var icon: String {
            switch self {
            case .fastFood: return "🍔"
            case .japanese: return "🍱"
            case .coffee: return "☕️"
            case .chinese: return "🥘"
            case .western: return "🍝"
            }
        }
        
        var displayName: String {
            switch self {
            case .fastFood: return "快餐"
            case .japanese: return "日式"
            case .coffee: return "咖啡"
            case .chinese: return "中餐"
            case .western: return "西餐"
            }
        }
    }
}

// API 响应模型
struct RestaurantsResponse: Codable {
    let restaurants: [Restaurant]
}
