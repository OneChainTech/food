import SwiftUI

struct RestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        NavigationLink(destination: RestaurantMatchView(restaurant: restaurant)) {
            VStack(alignment: .leading, spacing: 12) {
                // 餐厅图片
                if let imageUrl = restaurant.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(16/9, contentMode: .fit)
                                .cornerRadius(12)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                                .cornerRadius(12)
                                .clipped()
                        case .failure(_):
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(16/9, contentMode: .fit)
                                .cornerRadius(12)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(restaurant.type.icon)
                            .font(.title2)
                        Text(restaurant.name)
                            .font(.headline)
                        Spacer()
                        Text(restaurant.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text(restaurant.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}
