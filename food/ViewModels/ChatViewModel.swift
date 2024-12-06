import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func loadMessages() async {
        isLoading = true
        error = nil
        
        do {
            messages = try await ChatService.shared.loadMessages(with: userId)
        } catch {
            self.error = "加载消息失败：\(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func sendMessage(_ content: String) async {
        do {
            try await ChatService.shared.sendMessage(content, to: userId)
            // 模拟消息发送成功
            let message = Message(
                id: UUID().uuidString,
                senderId: "currentUser", // TODO: 替换为实际的当前用户ID
                receiverId: userId,
                content: content,
                timestamp: Date(),
                type: .text
            )
            messages.append(message)
        } catch {
            self.error = "发送消息失败：\(error.localizedDescription)"
        }
    }
}
