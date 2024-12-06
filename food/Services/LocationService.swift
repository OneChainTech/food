import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var locationError: String?
    @Published var isUpdatingLocation: Bool = false
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // 降低精度要求
        locationManager.distanceFilter = 100 // 增加距离过滤器
        
        print("LocationService initialized with status: \(authorizationStatus.rawValue)")
    }
    
    func requestLocationPermission() {
        print("Requesting location permission...")
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .denied {
            self.locationError = "请在设置中允许访问位置信息"
        }
    }
    
    func startUpdatingLocation() {
        print("Starting location updates...")
        locationError = nil // 清除之前的错误
        isUpdatingLocation = true
        
        // 检查是否已经有位置信息
        if let location = locationManager.location {
            self.currentLocation = location
            self.isUpdatingLocation = false
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        print("Stopping location updates...")
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            print("Authorization status changed to: \(manager.authorizationStatus.rawValue)")
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("Location permission granted, starting updates")
                self.startUpdatingLocation()
            case .denied:
                print("Location permission denied")
                self.locationError = "请在设置中允许访问位置信息"
                self.stopUpdatingLocation()
            case .restricted:
                print("Location permission restricted")
                self.locationError = "位置服务受限"
                self.stopUpdatingLocation()
            case .notDetermined:
                print("Location permission not determined")
                self.locationError = nil
            @unknown default:
                print("Unknown authorization status")
                self.locationError = "未知的位置权限状态"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            print("Location updated: \(location)")
            self.currentLocation = location
            self.locationError = nil
            
            // 获取到位置后停止更新
            if self.isUpdatingLocation {
                self.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("Location manager failed with error: \(error.localizedDescription)")
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.locationError = "请在设置中允许访问位置信息"
                case .locationUnknown:
                    self.locationError = "无法获取位置信息，请稍后重试"
                default:
                    self.locationError = "获取位置信息失败：\(error.localizedDescription)"
                }
            } else {
                self.locationError = "获取位置信息失败：\(error.localizedDescription)"
            }
            self.stopUpdatingLocation()
        }
    }
}
