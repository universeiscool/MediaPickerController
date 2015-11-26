Pod::Spec.new do |s|
  s.name         = "MediaPickerController"
  s.version      = "1.0.0"
  s.summary      = "Text entry controls which contain a built-in title/label so that you don't have to add a separate title for each field."
  s.homepage     = "https://github.com/FahimF/FloatLabelFields"
  s.screenshots  = "https://cloud.githubusercontent.com/assets/181110/5260534/f64efed4-7a4a-11e4-9b62-2cc1e009ee95.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Fahim Farook" => "" }
  s.social_media_url   = "http://twitter.com/FahimFarook"
  s.platform     = :ios
  s.ios.deployment_target	= '8.0'
  s.source       = { :git => "https://github.com/FahimF/FloatLabelFields" }
  s.source_files  = "FloatLabelFields/*.swift"
  s.frameworks   = ['Foundation', 'UIKit']
  s.requires_arc = true
end
