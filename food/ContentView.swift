//
//  ContentView.swift
//  food
//
//  Created by zhenghong on 2024/12/6.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject private var locationService: LocationService
    @StateObject private var viewModel: RestaurantViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: RestaurantViewModel(locationService: LocationService()))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch locationService.authorizationStatus {
                case .notDetermined:
                    RequestLocationView()
                case .restricted, .denied:
                    LocationDeniedView()
                case .authorizedWhenInUse, .authorizedAlways:
                    RestaurantListView(viewModel: viewModel)
                @unknown default:
                    Text("Unknown authorization status")
                }
            }
            .navigationTitle("附近餐厅")
        }
        .onAppear {
            print("ContentView appeared")
            viewModel.updateLocationService(locationService)
            
            if locationService.authorizationStatus == .notDetermined {
                locationService.requestLocationPermission()
            }
        }
    }
}

struct RequestLocationView: View {
    @EnvironmentObject private var locationService: LocationService
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 56))
            Text("需要位置权限")
                .font(.title2)
            Text("为了向您推荐附近的餐厅，我们需要获取您的位置信息")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Button(action: {
                print("Location permission button tapped")
                locationService.requestLocationPermission()
            }) {
                Text("允许使用位置信息")
                    .frame(minWidth: 200)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            print("RequestLocationView appeared")
        }
    }
}

struct LocationDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 56))
            Text("无法访问位置信息")
                .font(.title2)
            Text("请在设置中允许访问位置信息以使用完整功能")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Button("打开设置") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct RestaurantListView: View {
    @ObservedObject var viewModel: RestaurantViewModel
    @EnvironmentObject private var locationService: LocationService
    
    var body: some View {
        ZStack {
            if locationService.isUpdatingLocation {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("正在获取位置信息...")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            } else if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("正在获取餐厅信息...")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        locationService.startUpdatingLocation()
                    }) {
                        Label("重试", systemImage: "arrow.clockwise")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else if viewModel.restaurants.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("暂无附近餐厅")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Button(action: {
                        locationService.startUpdatingLocation()
                    }) {
                        Label("重新获取位置", systemImage: "arrow.clockwise")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.restaurants.prefix(3)) { restaurant in
                            RestaurantCard(restaurant: restaurant)
                                .frame(height: UIScreen.main.bounds.height * 0.25)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .refreshable {
                    locationService.startUpdatingLocation()
                }
            }
        }
        .onChange(of: locationService.currentLocation) { oldValue, newValue in
            print("Location changed from: \(String(describing: oldValue)) to: \(String(describing: newValue))")
            Task {
                await viewModel.refreshRestaurants()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationService())
}
