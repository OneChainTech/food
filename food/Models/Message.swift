import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let timestamp: Date
    let type: MessageType
    
    enum MessageType: String, Codable {
        case text
        case image
        case location
    }
}

struct Chat: Identifiable {
    let id: String
    let users: [User]
    let restaurant: Restaurant
    let lastMessage: Message?
    let unreadCount: Int
    let matchTime: Date
}
