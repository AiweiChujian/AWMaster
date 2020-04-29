#
# Be sure to run `pod lib lint AWMaster.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AWMaster'
  s.version          = '0.9.0'
  s.summary          = '组件化架构中间件，基于消息转发的组件间通信方案'
                       
  s.homepage         = 'https://github.com/AiweiChujian/AWMaster'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'aiweichujian' => 'hellohezhili@gmail.com' }
  s.source           = { :git => 'https://github.com/AiweiChujian/AWMaster.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'AWMaster/Classes/**/*'
  
  s.frameworks = 'UIKit'
  s.requires_arc = true

end
