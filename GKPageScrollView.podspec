Pod::Spec.new do |s|
  s.name             = 'GKPageScrollView'
  s.version          = '1.0.1'
  s.summary          = 'iOS UIScrollView嵌套滑动分页视图'
  s.homepage         = 'https://github.com/QuintGao/GKPageScrollView'
  s.license          = 'MIT'
  s.author           = { '高坤' => '1094887059@qq.com' }
  s.social_media_url = 'https://github.com/QuintGao'
  s.platform         = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  s.source           = { :git => "https://github.com/QuintGao/GKPageScrollView.git", :tag => s.version.to_s }
  s.source_files     = 'GKPageScrollView/**/*'
  s.public_header_files = "GKPageScrollView/**/*.h"
  s.frameworks       = "Foundation", "UIKit"
end
