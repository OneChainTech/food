import Foundation
import CoreLocation

struct User: Identifiable, Codable {
    let id: String
    let nickname: String
    let gender: Gender
    let avatar: String
    let preferences: [String]
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum Gender: String, Codable {
        case male = "male"
        case female = "female"
        
        var color: String {
            switch self {
            case .male: return "green"
            case .female: return "red"
            }
        }
        
        var displayName: String {
            switch self {
            case .male: return "男"
            case .female: return "女"
            }
        }
    }
}

// 匹配用户响应模型
struct MatchedUsersResponse: Codable {
    let users: [User]
}
