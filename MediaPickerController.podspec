Pod::Spec.new do |s|
  s.name         = "MediaPickerController"
  s.version      = "1.0.0"
  s.summary      = "Image Asset Picker for iOS 8 written in Swift."
  s.homepage     = "https://github.com/universeiscool/MediaPickerController"
  s.screenshots  = ""
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Malte Schonvogel" => "" }
  s.social_media_url   = "http://twitter.com/schonvogel"
  s.platform     = :ios
  s.ios.deployment_target	= '8.0'
  s.source       = { :git => "https://github.com/universeiscool/MediaPickerController.git" }
  s.source_files  = "MediaPickerController/*.swift"
  s.frameworks   = ['Foundation', 'UIKit']
  s.requires_arc = true
end
