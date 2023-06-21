workspace 'GKPageScrollView.xcworkspace'

target 'ObjcExample' do
  platform :ios, '9.0'
  project 'ObjcExample/ObjcExample.xcodeproj'

  pod 'GKPageScrollView', :path => '../GKPageScrollView'
  pod 'GKPageSmoothView', :path => '../GKPageScrollView'
  pod 'GKNavigationBar'
  pod 'Masonry'
  pod 'WMPageController'
  pod 'MJRefresh'
  pod 'JXCategoryViewExt/SubTitleImage'
  pod 'JXCategoryViewExt/Indicator/AlignmentLine'
  pod 'VTMagic'
end

target 'SwiftExample' do
  platform :ios, '9.0'
  project 'SwiftExample/SwiftExample.xcodeproj'
  
  use_frameworks!
  
  pod 'GKPageScrollView/Swift', :path => '../GKPageScrollView'
  pod 'GKPageSmoothView/Swift', :path => '../GKPageScrollView'
  pod 'GKNavigationBarSwift'
  pod 'SnapKit'
  pod 'MJRefresh'
  pod 'WMPageController'
  pod 'JXSegmentedViewExt/Number'
  pod 'JXSegmentedViewExt/SubTitleImage'
  pod 'JXSegmentedViewExt/Indicator/AlignmentLine'
#  pod 'JXCategoryViewExt/SubTitleImage'
#  pod 'JXCategoryViewExt/Indicator/AlignmentLine'
  pod 'VTMagic'
end

target 'SwiftUIExample' do
  platform :ios, '9.0'
  project 'SwiftUIExample/SwiftUIExample.xcodeproj'
  
  use_frameworks!
  
  pod 'GKPageScrollView/Swift', :path => '../GKPageScrollView'
  pod 'SnapKit'
  pod 'JXSegmentedViewExt/Title'
  pod 'JXSegmentedViewExt/Indicator/Line'
  
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
