#
# Be sure to run `pod lib lint FunBox.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FunBox'
  s.version          = '0.3.1'
  s.summary          = 'FunBox 饭盒？'
  s.swift_version    = '5.0'
  
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/choarkinphe/FunBox'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'choarkinphe' => 'choarkinphe@outlook.com' }
  s.source           = { :git => 'https://github.com/choarkinphe/FunBox.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  # 核心库
  s.subspec 'Core' do |core|
      # 核心库路径
      core.source_files = 'FunBox/Core/Code/**/*'
      # 核心库Bundle地址
      #core.resource_bundles = {
          #'FunCore' => ['FunBox/Core/Assets/*.{storyboard,xib,xcassets,json,imageset,png,md}']
      #}
  end
  
      # 组件库
      s.subspec 'Modules' do |modules|
          # 组件库公共路径
          modules.source_files = 'FunBox/Modules/Main/**/*'
          modules.dependency 'FunBox/Core'
          # 工具: FunNetworking
          modules.subspec 'Networking' do |networking|
              # FunNetworking路径
              networking.source_files = 'FunBox/Modules/Networking/Code/**/*'
              # FunNetworking的Bundle地址
              #networking.resource_bundles = {
                  #'FunNetworking' => ['HZCoreKit/Modules/Networking/Assets/*.{storyboard,xib,xcassets,json,imageset,png,md}']
              #}
              # FunNetworking依赖
              networking.dependency 'Alamofire', '~> 5.2.2'
          end
      end

  #s.source_files = 'FunBox/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FunBox' => ['FunBox/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
