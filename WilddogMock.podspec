Pod::Spec.new do |s|
  s.name         = "WilddogVideoBase"
  s.version      = "9.9.9"
  s.summary      = "WilddogVideoBase 的源码集成版本。"

  s.description  = <<-DESC
WilddogVideoBase 的源码集成版本。供内部开发使用。
                   DESC

  s.homepage     = "https://www.wilddog.com/"
  s.license      = "MIT"
  s.author       = "Wilddog Team"
  s.platform     = :ios, "8.0"

  s.source       = { :git => "http://gitlab.wilddog.cn/ios/WilddogVideoBase.git", :tag => "#{s.version}" }
  s.public_header_files = "WilddogVideoBase/**/*.{h}"
  s.source_files  = "WilddogVideoBase/**/*.{h,m,mm}"

  s.module_map = 'WilddogVideoBase/WilddogVideoBase.modulemap' 
  s.frameworks   = "AudioToolbox", "VideoToolbox", "AVFoundation", "GLKit", "CoreMedia", "UIKit", "Foundation"
  s.libraries   = "c++"
  s.xcconfig     = { 'OTHER_LDFLAGS' => '-ObjC' }
  s.prefix_header_file = 'WilddogVideoBase/PrefixHeader.pch'

  s.dependency "WilddogCore"
  s.dependency "WilddogWebRTC", '>=58.0.11'
end