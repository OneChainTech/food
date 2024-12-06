import Foundation
import CoreLocation

@MainActor
class MatchingViewModel: ObservableObject {
    @Published var matchedUsers: [User] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedUser: User?
    @Published var matchRequestStatus: MatchRequestStatus?
    
    private let restaurant: Restaurant
    private let locationService: LocationService
    
    enum MatchRequestStatus {
        case sending
        case accepted
        case rejected
        case failed(String)
    }
    
    init(restaurant: Restaurant, locationService: LocationService) {
        self.restaurant = restaurant
        self.locationService = locationService
    }
    
    func findMatches(at time: Date) async {
        guard let currentLocation = locationService.currentLocation else {
            error = "无法获取位置信息"
            return
        }
        
        isLoading = true
        error = nil
        matchedUsers = []
        
        do {
            let users = try await MatchingService.shared.findMatches(
                at: restaurant,
                time: time,
                currentLocation: currentLocation
            )
            matchedUsers = users
        } catch {
            self.error = "查找匹配用户失败：\(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func sendMatchRequest(to user: User) async {
        selectedUser = user
        matchRequestStatus = .sending
        
        do {
            let accepted = try await MatchingService.shared.sendMatchRequest(to: user.id)
            matchRequestStatus = accepted ? .accepted : .rejected
        } catch {
            matchRequestStatus = .failed(error.localizedDescription)
        }
    }
    
    func resetMatchRequest() {
        selectedUser = nil
        matchRequestStatus = nil
    }
}
