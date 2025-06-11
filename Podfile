platform :ios, '12.0'
use_frameworks!

target 'SwiftTask' do
  pod 'Alamofire', '~> 5.9'
end

target 'SwiftTask-iOSTests' do
  pod 'Alamofire', '~> 5.9'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['SWIFT_VERSION'] = '6.0'
    end
  end
end
