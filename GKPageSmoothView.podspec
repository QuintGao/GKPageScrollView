Pod::Spec.new do |s|
  s.name                = 'GKPageSmoothView'
  s.version             = '1.9.6'
  s.summary             = 'iOS UIScrollView嵌套滑动分页视图'
  s.homepage            = 'https://github.com/QuintGao/GKPageScrollView'
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { 'QuintGao' => '1094887059@qq.com' }
  s.social_media_url    = 'https://github.com/QuintGao'
  s.ios.deployment_target = '9.0'
  s.source              = { :git => "https://github.com/QuintGao/GKPageScrollView.git", :tag => s.version.to_s }
  s.swift_version       = '5.0'
  s.default_subspec     = 'Objc'
  
  s.subspec 'Objc' do |ss|
    ss.source_files = 'Sources/GKPageSmoothView/*.{h,m}'
    ss.resource_bundles = {'GKPageSmoothView' => 'Sources/GKPageSmoothView/PrivacyInfo.xcprivacy'}
  end
  
  s.subspec 'Swift' do |ss|
    ss.source_files = 'Sources/GKPageSmoothViewSwift/*.swift'
    ss.libraries = 'swiftCoreGraphics'
    ss.xcconfig = {
      'LIBRARY_SEARCH_PATHS' => '$(SDKROOT)/usr/lib/swift',
    }
    ss.resource_bundles = {'GKPageSmoothView' => 'Sources/GKPageSmoothViewSwift/PrivacyInfo.xcprivacy'}
  end
end
