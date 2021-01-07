Pod::Spec.new do |s|
  s.name                = 'GKPageScrollView'
  s.version             = '1.5.2'
  s.summary             = 'iOS UIScrollView嵌套滑动分页视图'
  s.homepage            = 'https://github.com/QuintGao/GKPageScrollView'
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { '高坤' => '1094887059@qq.com' }
  s.social_media_url    = 'https://github.com/QuintGao'
  s.ios.deployment_target = '9.0'
  s.source              = { :git => "https://github.com/QuintGao/GKPageScrollView.git", :tag => s.version.to_s }
  s.swift_version       = '5.0'
  s.default_subspec     = 'Objc'
  
  s.subspec 'Objc' do |ss|
    ss.source_files = 'Sources/GKPageScrollView/*.{h,m}'
  end
  
  s.subspec 'Swift' do |ss|
    ss.source_files  = 'Sources/GKPageScrollViewSwift/*.swift'
  end
end
