import Foundation

class ChatService {
    static let shared = ChatService()
    
    private init() {}
    
    func sendMessage(_ content: String, to userId: String) async throws {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // TODO: 实际发送消息到服务器
    }
    
    func loadMessages(with userId: String) async throws -> [Message] {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: 从服务器加载消息历史
        return []
    }
    
    func loadChats() async throws -> [Chat] {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: 从服务器加载聊天列表
        return []
    }
}
