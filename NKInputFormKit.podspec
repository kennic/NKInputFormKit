#
# Be sure to run `pod lib lint NKInputFormKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NKInputFormKit'
  s.version          = '1.5'
  s.summary          = 'A base class help you to create variations of form views easily'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A base class help you to create variations of form views easily like: Login dialog, SignUp dialog, Password dialog.
                       DESC

  s.homepage         = 'https://github.com/kennic/NKInputFormKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nam Kennic' => 'namkennic@me.com' }
  s.source           = { :git => 'https://github.com/kennic/NKInputFormKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/namkennic'

  s.ios.deployment_target = '9.0'

  s.source_files = 'NKInputFormKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'NKInputFormKit' => ['NKInputFormKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
