workspace 'GKPageScrollView.xcworkspace'

target 'GKPageScrollViewObjc' do
  platform :ios, '9.0'
  project 'GKPageScrollViewObjc/GKPageScrollViewObjc.xcodeproj'

  pod 'GKNavigationBar'
  pod 'Masonry'
  pod 'WMPageController'
  pod 'MJRefresh'
  pod 'JXCategoryView'
  pod 'VTMagic'
end

target 'GKPageScrollViewSwift' do
  platform :ios, '9.0'
  project 'GKPageScrollViewSwift/GKPageScrollViewSwift.xcodeproj'
  
  use_frameworks!
  
  pod 'GKNavigationBarSwift'
  pod 'SnapKit'
  pod 'MJRefresh'
  pod 'WMPageController'
  pod 'JXSegmentedView'
  pod 'VTMagic'
end

post_install do |installer|
  # 消除版本警告
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
