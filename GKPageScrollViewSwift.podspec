Pod::Spec.new do |s|
  s.name                = 'GKPageScrollViewSwift'
  s.version             = '1.3.5'
  s.summary             = 'iOS UIScrollView嵌套滑动分页视图'
  s.homepage            = 'https://github.com/QuintGao/GKPageScrollView'
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { '高坤' => '1094887059@qq.com' }
  s.social_media_url    = 'https://github.com/QuintGao'
  s.platform            = :ios, "8.0"
  s.source              = { :git => "https://github.com/QuintGao/GKPageScrollView.git", :tag => s.version }
  s.source_files        = 'GKPageScrollView/swift/*.{swift}'
  s.swift_version 	    = '5.0'
  s.requires_arc 	    = true
end
