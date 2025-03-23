import SwiftUI
import MapKit
import CoreLocation

@available(iOS 17.0, *)
struct MainScreen: View {
    @StateObject private var locationDelegate = LocationManagerDelegate()
    private let locationManager = CLLocationManager()
    
    // 创建 MapCameraPosition 的绑定
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    
    var body: some View {
        VStack {
            // 使用新的 Map 初始化方法
            Map(position: $cameraPosition, interactionModes: .all) {
                // 添加用户位置注解
                UserAnnotation()
            }
            .frame(height: 300)
            .onAppear {
                locationDelegate.requestLocationPermission()
            }
            
            // “回到我的位置”按钮
            Button(action: {
                centerMapOnUserLocation()
            }) {
                Text("回到我的位置")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // 运动状态显示
            VStack {
                Text("当前距离: \(String(format: "%.2f", locationDelegate.currentDistance)) km")
                    .font(.headline)
                    .padding()
                Text(locationDelegate.userCoordinates)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // 开始/停止跑步按钮
            Button(action: {
                locationDelegate.toggleRunning()
            }) {
                Text(locationDelegate.isRunning ? "停止跑步" : "开始跑步")
                    .font(.title2)
                    .padding()
                    .background(locationDelegate.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    // 回到用户当前位置：更新 cameraPosition 为用户当前坐标
    private func centerMapOnUserLocation() {
        if let location = locationDelegate.userLocation {
            withAnimation {
                cameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
            }
        }
    }
}

// 自定义注解类型，符合 Identifiable 协议
@available(iOS 17.0, *)
struct UserLocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// 为 LocationManagerDelegate 扩展提供注解数组
@available(iOS 17.0, *)
extension LocationManagerDelegate {
    var annotationItems: [UserLocationAnnotation] {
        if let loc = userLocation {
            return [UserLocationAnnotation(coordinate: loc)]
        } else {
            return []
        }
    }
}

// 位置管理类
@available(iOS 17.0, *)
class LocationManagerDelegate: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var route: [CLLocationCoordinate2D] = []
    @Published var currentDistance: Double = 0.0
    @Published var isRunning: Bool = false
    @Published var userCoordinates: String = "Latitude: N/A, Longitude: N/A"
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5  // 每 5 米更新一次
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.userCoordinates = "Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)"
            
            // 如果正在跑步，则记录轨迹并累加距离
            if self.isRunning {
                if let previous = self.route.last {
                    let distance = location.distance(from: CLLocation(latitude: previous.latitude, longitude: previous.longitude))
                    self.currentDistance += distance / 1000.0 // 转换为 km
                }
                self.route.append(location.coordinate)
                print(location.coordinate, " added into ", self.route)
            }
        }
    }
    
    func toggleRunning() {
        DispatchQueue.main.async {
            self.isRunning.toggle()
            if self.isRunning {
                self.route.removeAll()
                self.currentDistance = 0.0
            }
        }
    }
}

@available(iOS 17.0, *)
struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
