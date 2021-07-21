#
# Be sure to run `pod lib lint CoreKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'CoreKit'
    s.version          = '1.0.1'
    s.summary          = '基于饭盒(FunBox)的开发框架'
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
    s.source_files = 'Sources/DevelopKit/CoreKit/Code/CoreKit.swift'
    
    #依赖
    s.dependency 'FunBox/Core', '~> 1.0.0'
    s.dependency 'FunModules/FunUI'
    s.dependency 'FunModules/RxFunBox'
    s.dependency 'Hue', '~> 5.0.0'
    s.dependency 'HandyJSON', '~> 5.0.2'
    s.dependency 'Kingfisher', '~> 5.15.0'
    #    s.dependency 'libwebp', '~> 1.1.0'#, :git => 'https://github.com/webmproject/libwebp.git'
    s.dependency 'KingfisherWebP', '~> 1.0.0'
    s.dependency 'MJRefresh', '~> 3.5.0'
    s.dependency 'Moya/RxSwift', '~> 14.0.0'
    s.dependency 'RxAlamofire', '~> 5.6.0'
    s.dependency 'RxDataSources', '~> 4.0.1'
    s.dependency 'RxSwift', '~> 5.1.1'
    s.dependency 'RxCocoa', '~> 5.1.1'
    s.dependency 'SnapKit', '~> 5.0.1'
    s.subspec 'Core' do |ss|

    s.subspec 'Core' do |core|
        # 核心库路径
        core.dependency 'CoreKit/Box/Extension'
        core.dependency 'CoreKit/Box/Service'
        core.dependency 'CoreKit/Box/CKUIKit'
        core.dependency 'CoreKit/Box/Utils'
    end
        
    s.subspec 'Main' do |main|
        # 路径
        main.source_files = 'Sources/CoreKit/Core/Code/*'
        # 核心库Bundle地址
        main.resource_bundles = {
            'CoreKit' => ['Sources/CoreKit/Core/Assets/**/*.{storyboard,xib,xcassets,json,imageset,png,gif,md}']
        }
    end
        
        
    s.subspec 'Box' do |box|
        box.subspec 'CKUIKit' do |item|
            # 路径
            item.source_files = 'Sources/CoreKit/Core/Code/HZUIKit/**/*'
            # 依赖
            item.dependency 'CoreKit/Box/Extension'
            item.dependency 'CoreKit/Box/Service'
        end
        
        box.subspec 'Extension' do |item|
            # 路径
            item.source_files = 'Sources/CoreKit/Core/Code/Extension/**/*'
            # 依赖
            item.dependency 'CoreKit/Box/Service'
        end
            
        box.subspec 'Service' do |item|
            # 路径
            item.source_files = 'Sources/CoreKit/Core/Code/Service/**/*'
            # 依赖
            item.dependency 'CoreKit/Main'
        end
        
        box.subspec 'Utils' do |item|
            # 路径
            item.source_files = 'Sources/CoreKit/Core/Code/Utils/**/*'
            # 依赖
            item.dependency 'CoreKit/Box/Extension'
            item.dependency 'CoreKit/Box/Service'
        end
    end
        
        
    # 组件库
    s.subspec 'Modules' do |modules|

        modules.dependency 'CoreKit/Core'
    end

        
    end

end
