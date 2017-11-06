Pod::Spec.new do |s|
  s.name                = "WilddogVideo"
  s.version             = "1.1.1"
  s.summary             = "Wilddog video module for iOS"

  s.description         = <<-DESC
                          The video module lets you make realtime media communication.
                          DESC

  s.homepage            = "https://www.wilddog.com/"
  s.license             = "Copyright"
  s.author              = "Wilddog Team"
  s.platform            = :ios, "8.0"

  s.source              = { :http => "https://cdn.wilddog.com/sdk/ios/1.1.1/WilddogVideo-1.1.1.zip"}

  s.vendored_frameworks = "WilddogVideo.framework"

  s.frameworks          = "AudioToolbox", "VideoToolbox", "AVFoundation", "GLKit", "CoreMedia", "UIKit", "Foundation", "MetalKit"
  s.library             = "c++"
  s.xcconfig            = { "OTHER_LDFLAGS" => "-ObjC" }

  s.dependency "WilddogVideoBase", ">= 2.0.0"
  s.dependency "WilddogAuth", ">= 2.0.2"
  s.dependency "WilddogWebRTC", ">= 58.0.11"
end
