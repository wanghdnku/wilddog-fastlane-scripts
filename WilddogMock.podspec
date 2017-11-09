Pod::Spec.new do |s|
  s.name         = "WilddogMock"
  s.version      = "0.0.1"
  s.summary      = "WilddogMock 的源码集成版本。"

  s.description  = <<-DESC
                   WilddogMock 的源码集成版本。供内部开发使用。
                   DESC

  s.homepage     = "https://www.wilddog.com/"
  s.license      = "MIT"
  s.author       = "Wilddog Team"
  s.platform     = :ios, "8.0"

  s.source       = { :git => "git@gitlab.wilddog.cn:wanghaidong/fastlane-script.git", :tag => "#{s.version}" }
  s.public_header_files = "WilddogMock/**/*.{h}"
  s.source_files  = "WilddogMock/**/*.{h,m,mm}"

  s.module_map = 'WilddogMock/WilddogMock.modulemap' 
  s.frameworks   = "AudioToolbox", "VideoToolbox", "AVFoundation", "GLKit", "CoreMedia", "UIKit", "Foundation"
  s.libraries   = "c++"
  s.xcconfig     = { 'OTHER_LDFLAGS' => '-ObjC' }
  s.prefix_header_file = 'WilddogMock/PrefixHeader.pch'

  s.dependency "WilddogVideoBase"

end
