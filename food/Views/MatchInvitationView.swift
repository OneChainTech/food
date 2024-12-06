import SwiftUI

struct MatchInvitation: Identifiable {
    let id: String
    let sender: User
    let restaurant: Restaurant
    let time: Date
}

struct MatchInvitationView: View {
    let invitation: MatchInvitation
    let onAccept: () -> Void
    let onReject: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // 头像和昵称
            VStack(spacing: 12) {
                Image(invitation.sender.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(invitation.sender.gender == .male ? Color.blue : Color.pink, lineWidth: 2))
                
                Text(invitation.sender.nickname)
                    .font(.title3)
                    .bold()
            }
            
            // 邀请信息
            VStack(spacing: 8) {
                Text("邀请你一起去")
                    .foregroundColor(.gray)
                
                Text(invitation.restaurant.name)
                    .font(.headline)
                
                Text(formatDate(invitation.time))
                    .foregroundColor(.gray)
            }
            
            // 操作按钮
            HStack(spacing: 20) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onReject()
                    dismiss()
                }) {
                    Text("婉拒")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(width: 100)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 2)
                        )
                }
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onAccept()
                    dismiss()
                }) {
                    Text("接受")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}
