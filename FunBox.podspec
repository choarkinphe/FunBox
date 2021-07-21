#
# Be sure to run `pod lib lint FunBox.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'FunBox'
    s.version          = '1.0.1'
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
    
    s.ios.deployment_target = '11.0'
    
    # 核心库
    s.source_files = 'Sources/FunBox/Code/*'

    s.subspec 'Core' do |ss|
        # 核心库依赖
        ss.dependency 'FunBox/Fun'
        ss.dependency 'FunBox/Box'
    end
    
    s.subspec 'Fun' do |ss|
        # 核心库路径
        ss.source_files = 'Sources/FunBox/Code/*','Sources/FunBox/Code/Core/**/*'
        # Bundle地址
        ss.resource_bundles = {
            'FunBox' => ['Sources/FunBox/Assets/**/*.{storyboard,xib,xcassets,json,imageset,png,md,strings}']
        }
    end
    
    s.subspec 'Box' do |ss|

        ss.subspec 'Utils' do |sss|
            # 路径
            sss.source_files = 'Sources/FunBox/Code/Utils/**/*'
            # 依赖
            sss.dependency 'FunBox/Fun'
        end
        ss.subspec 'UI' do |sss|
            # 路径
            sss.source_files = 'Sources/FunBox/Code/UI/**/*'
            # 依赖
            sss.dependency 'FunBox/Fun'
        end
    end

    end
    
