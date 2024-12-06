import SwiftUI

struct ChatView: View {
    let user: User
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    
    init(user: User) {
        self.user = user
        _viewModel = StateObject(wrappedValue: ChatViewModel(userId: user.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 消息列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message, isFromCurrentUser: message.senderId == "currentUser")
                    }
                }
                .padding()
            }
            
            // 输入栏
            HStack(spacing: 12) {
                TextField("发送消息...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                
                Button(action: {
                    guard !messageText.isEmpty else { return }
                    let content = messageText
                    messageText = ""
                    
                    Task {
                        await viewModel.sendMessage(content)
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 5, y: -5)
        }
        .navigationTitle(user.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMessages()
        }
    }
}

// 消息气泡
struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            Text(message.content)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isFromCurrentUser ? Color.blue : Color(.systemGray6))
                )
                .foregroundColor(isFromCurrentUser ? .white : .primary)
            
            if !isFromCurrentUser { Spacer() }
        }
    }
}
