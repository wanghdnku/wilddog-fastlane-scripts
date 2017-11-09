Pod::Spec.new do |s|
  s.name                = "WilddogMock"
  s.version             = "0.0.1"
  s.summary             = "WilddogMock project is just for testing fastlane script."

  s.description         = <<-DESC
                          DO NOT integrate this framework.
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

  s.dependency "WilddogVideoBase", "~> 2.1.0"

end
