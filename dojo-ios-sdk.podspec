#
# Be sure to run `pod lib lint dojo-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'dojo-ios-sdk'
  s.version          = '0.2.0'
  s.summary          = 'A short description of dojo-ios-sdk.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/dojo-engineering/dojo-ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Deniss Kaibagarovs' => 'deniss.kaibagarovs@paymentsense.com' }
  s.source           = { :git => 'https://github.com/dojo-engineering/dojo-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'dojo-ios-sdk/Classes/**/*'
  s.public_header_files = 'dojo-ios-sdk/Classes/**/*.h'
  
  s.test_spec 'dojo-ios-sdk-tests' do |test_spec|
      test_spec.source_files = 'dojo-ios-sdk/Tests/**/*'
  end
  
  # s.resource_bundles = {
  #   'dojo-ios-sdk' => ['dojo-ios-sdk/Assets/*.png']
  # }

   
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
