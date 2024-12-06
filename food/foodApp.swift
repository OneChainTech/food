//
//  foodApp.swift
//  food
//
//  Created by zhenghong on 2024/12/6.
//

import SwiftUI

@main
struct foodApp: App {
    // 将 LocationService 移到 App 级别
    @StateObject private var locationService = LocationService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationService) // 通过环境对象传递 LocationService
        }
    }
}
