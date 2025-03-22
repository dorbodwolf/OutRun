project 'OutRun.xcodeproj'
platform :ios, '16.0'

def ui_pods
  pod 'SnapKit'
  pod 'Charts'
  # pod 'JTAppleCalendar'
end

def data_pods
  pod 'Cache', '~> 6.0'
  pod 'CombineExt'

  pod 'CoreStore', '~> 9.1.0'
  pod 'CoreGPX', '~> 0.9.0'
end

target 'OutRun' do
  use_frameworks!

  ui_pods
  data_pods

  target 'UnitTests' do
    inherit! :search_paths
  end

end
