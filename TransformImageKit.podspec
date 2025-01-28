Pod::Spec.new do |s|
  s.name             = 'TransformImageKit'
  s.version          = '1.0.0'
  s.summary          = 'A Swift library for image transformations.'
  s.description      = <<-DESC
                       TransformImageKit provides a set of tools to resize, convert, and manage images efficiently in Swift.
                       DESC

  s.homepage         = 'https://github.com/tusharvijay24/TransformImageKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tusharvijay24' => 'tusharvijayvargiya24112000@gmail.com' }
  s.source           = { :git => 'https://github.com/tusharvijay24/TransformImageKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'TransformImageKit/Classes/**/*'

   s.frameworks = 'UIKit'
   s.dependency 'IQKeyboardManager'
   s.dependency 'SDWebImage'
   s.dependency 'ZIPFoundation'
end
