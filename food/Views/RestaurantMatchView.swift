import SwiftUI
import MapKit

// 地图标注项
enum MapItem: Identifiable {
    case restaurant(Restaurant)
    case user(User)
    
    var id: String {
        switch self {
        case .restaurant(let restaurant): return "r_\(restaurant.id)"
        case .user(let user): return "u_\(user.id)"
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .restaurant(let restaurant): return restaurant.coordinate
        case .user(let user): return user.coordinate
        }
    }
}

// 地图标注项协议
protocol MapAnnotationItem: Identifiable {
    var coordinate: CLLocationCoordinate2D { get }
}

// 扩展 Restaurant 以符合 MapAnnotationItem 协议
extension Restaurant: MapAnnotationItem {}

// 扩展 User 以符合 MapAnnotationItem 协议
extension User: MapAnnotationItem {}

struct RestaurantMatchView: View {
    let restaurant: Restaurant
    @StateObject private var viewModel: MatchingViewModel
    @EnvironmentObject private var locationService: LocationService
    @State private var selectedDate = Date()
    @State private var region: MKCoordinateRegion
    @State private var showingDatePicker = false
    @State private var showingUserProfile = false
    @State private var isRefreshing = false
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        // 初始化地图区域，以餐厅位置为中心
        _region = State(initialValue: MKCoordinateRegion(
            center: restaurant.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        
        // 初始化 ViewModel
        _viewModel = StateObject(wrappedValue: MatchingViewModel(
            restaurant: restaurant,
            locationService: LocationService()
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 地图视图
            ZStack {
                Map(initialPosition: .region(region)) {
                    // 餐厅标注
                    Marker("餐厅", coordinate: restaurant.coordinate)
                        .tint(.red)
                    
                    // 用户标注
                    ForEach(viewModel.matchedUsers) { user in
                        Annotation(user.nickname, coordinate: user.coordinate) {
                            UserAnnotationView(user: user)
                                .onTapGesture {
                                    // 添加触感反馈
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    viewModel.selectedUser = user
                                    showingUserProfile = true
                                }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(8)
                }
            }
            .frame(height: 300)
            
            // 餐厅信息和时间选择
            ScrollView {
                RefreshControl(isRefreshing: $isRefreshing, onRefresh: {
                    Task {
                        await viewModel.findMatches(at: selectedDate)
                        isRefreshing = false
                    }
                })
                
                VStack(spacing: 16) {
                    // 餐厅信息卡片
                    RestaurantInfoCard(restaurant: restaurant)
                    
                    // 时间选择按钮
                    Button(action: {
                        // 添加触感反馈
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingDatePicker = true
                    }) {
                        HStack {
                            Image(systemName: "clock")
                            Text(formatDate(selectedDate))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                        )
                    }
                    
                    // 匹配按钮
                    Button(action: {
                        // 添加触感反馈
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        Task {
                            await viewModel.findMatches(at: selectedDate)
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(viewModel.matchedUsers.isEmpty ? "开始匹配" : "重新匹配")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                    .disabled(viewModel.isLoading)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(selectedDate: $selectedDate, isPresented: $showingDatePicker)
        }
        .sheet(isPresented: $showingUserProfile) {
            if let user = viewModel.selectedUser {
                UserProfileView(user: user, viewModel: viewModel)
            }
        }
        .alert("匹配失败", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("确定", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

// 用户标注视图
struct UserAnnotationView: View {
    let user: User
    
    var body: some View {
        Image(user.avatar)
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(Circle().stroke(user.gender == .male ? Color.blue : Color.pink, lineWidth: 2))
            .background(Circle().fill(.white))
            .shadow(radius: 3)
    }
}

// 餐厅信息卡片
struct RestaurantInfoCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(restaurant.type.icon)
                    .font(.title2)
                Text(restaurant.name)
                    .font(.headline)
                Spacer()
                Text(restaurant.type.displayName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text(restaurant.address)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Label(restaurant.priceLevel, systemImage: "dollarsign.circle")
                Spacer()
                Label(String(format: "%.1f", restaurant.rating), systemImage: "star.fill")
                    .foregroundColor(.orange)
                Spacer()
                Label(restaurant.openTime, systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        )
    }
}

// 用户资料视图
struct UserProfileView: View {
    let user: User
    @ObservedObject var viewModel: MatchingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingMatchAnimation = false
    @State private var showingChat = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 用户头像
            Image(user.avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(user.gender == .male ? Color.blue : Color.pink, lineWidth: 3))
            
            // 用户信息
            VStack(spacing: 8) {
                Text(user.nickname)
                    .font(.title2)
                    .bold()
                
                Text(user.gender.displayName)
                    .foregroundColor(.gray)
            }
            
            // 偏好标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(user.preferences, id: \.self) { preference in
                        Text(preference)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // 匹配按钮或状态
            if viewModel.matchRequestStatus == nil {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    Task {
                        await viewModel.sendMatchRequest(to: user)
                    }
                }) {
                    Text("发送匹配请求")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                }
            } else {
                VStack(spacing: 16) {
                    switch viewModel.matchRequestStatus {
                    case .sending:
                        ProgressView("发送中...")
                    case .accepted:
                        VStack(spacing: 16) {
                            MatchStatusView(
                                systemName: "checkmark.circle.fill",
                                text: "对方已接受",
                                color: .green
                            )
                            
                            // 添加聊天按钮
                            Button(action: {
                                showingChat = true
                            }) {
                                Label("开始聊天", systemImage: "message.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                            }
                        }
                        .onAppear {
                            showingMatchAnimation = true
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    case .rejected:
                        MatchStatusView(
                            systemName: "xmark.circle.fill",
                            text: "对方已拒绝",
                            color: .red
                        )
                        .onAppear {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    case .failed(let error):
                        MatchStatusView(
                            systemName: "exclamationmark.circle.fill",
                            text: error,
                            color: .orange
                        )
                        .onAppear {
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        }
                    case .none:
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            ZStack {
                if showingMatchAnimation {
                    Color.black.opacity(0.3)
                    
                    LottieView(name: "match_success")
                        .frame(width: 200, height: 200)
                }
            }
            .opacity(showingMatchAnimation ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: showingMatchAnimation)
            .onAppear {
                if case .accepted = viewModel.matchRequestStatus {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingMatchAnimation = false
                    }
                }
            }
        )
        .sheet(isPresented: $showingChat) {
            NavigationView {
                ChatView(user: user)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// 匹配状态视图
struct MatchStatusView: View {
    let systemName: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(color)
            Text(text)
                .foregroundColor(.primary)
        }
        .font(.headline)
    }
}

// Lottie 动画视图
struct LottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        // 注意：这里需要添加 Lottie 依赖并实现动画
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// 日期选择器视图
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("选择用餐时间",
                          selection: $selectedDate,
                          in: Date()...,
                          displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
            .padding()
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                },
                trailing: Button("确定") {
                    isPresented = false
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("选择用餐时间")
        }
    }
}

// 下拉刷新控件
struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY > 50 {
                VStack {
                    Spacer()
                    ProgressView()
                        .onAppear {
                            if !isRefreshing {
                                isRefreshing = true
                                onRefresh()
                            }
                        }
                }
            }
        }.frame(height: 0)
    }
}

#Preview {
    RestaurantMatchView(restaurant: Restaurant(
        id: "test",
        name: "测试餐厅",
        type: .chinese,
        address: "测试地址",
        latitude: 31.2304,
        longitude: 121.4737,
        rating: 4.5,
        priceLevel: "¥¥",
        openTime: "10:00-22:00",
        imageUrl: nil
    ))
}
