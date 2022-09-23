#
# Be sure to run `pod lib lint IosAwnFcmCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IosAwnFcmCore'
  s.version          = '0.7.0-alpha.2'
  s.summary          = 'Awesome Notifications Firebase Core.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Rafael Setragni/IosAwnFcmCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Copyright', :file => 'LICENSE' }
  s.author           = { 'Rafael Setragni' => '40064496+rafaelsetragni@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/rafaelsetragni/IosAwnFcmCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.dependency 'IosAwnCore', '0.7.0-alpha.2'

  s.source_files = 'IosAwnFcmCore/Classes/**/*'
  
  s.static_framework = true
  s.platform = :ios
  s.swift_version = '5.3'
  s.ios.deployment_target = '11.0'
  
  s.pod_target_xcconfig = {
    'SKIP_INSTALL' => 'NO',
    #'ENABLE_BITCODE' => 'NO',
    'APPLICATION_EXTENSION_API_ONLY' => 'NO',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }
  
end