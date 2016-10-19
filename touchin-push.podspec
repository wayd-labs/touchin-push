#
# Be sure to run `pod lib lint touchin-analytics.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "touchin-push"
  s.version          = "0.4.4"
  s.summary          = "iOS push notification the easy way."
  s.homepage         = "https://github.com/touchinstinct/touchin-push"
  s.license          = 'MIT'
  s.author           = { "alarin" => "me@alarin.ru" }
  s.source           = { :git => "https://github.com/touchinstinct/touchin-push.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.public_header_files = 'Pod/Classes/*.h'
  s.source_files = 'Pod/Classes'
#  s.resources = 'Pod/Assets'
  s.resource_bundles = {
    'TIPush' => ['Pod/Assets/*.xib', 'Pod/Assets/*.lproj']
  }

  s.dependency  'touchin-analytics/CoreIOS'
  s.frameworks = 'UIKit'
end
