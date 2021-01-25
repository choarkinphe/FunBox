#
# Be sure to run `pod lib lint FunBox.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'FunBox'
    s.version          = '0.5.60'
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
#        ss.subspec 'Extension' do |sss|
#            # 路径
#            sss.source_files = 'Sources/FunBox/Code/Extension/**/*'
#            # 依赖
#            sss.dependency 'FunBox/Main'
#
#        end
        ss.subspec 'Utils' do |sss|
            # 路径
            sss.source_files = 'Sources/FunBox/Code/Utils/**/*'
            # 依赖
#            sss.dependency 'FunBox/Box/Extension'
            sss.dependency 'FunBox/Fun'
        end
        ss.subspec 'UI' do |sss|
            # 路径
            sss.source_files = 'Sources/FunBox/Code/UI/**/*'
            # 依赖
#            sss.dependency 'FunBox/Box/Extension'
            sss.dependency 'FunBox/Fun'
        end
    end

    
    # 组件库
    s.subspec 'Modules' do |ss|
        ss.dependency 'FunBox/Core'
        # 组件库
        # 工具: FunAlamofire
        ss.subspec 'FunAlamofire' do |item|
            # FunAlamofire路径
            item.source_files = 'Sources/FunAlamofire/Code/**/*'
            # FunAlamofire依赖
#            item.dependency 'FunBox/Core'
            item.dependency 'Alamofire', '~> 5.2.2'
        end
        
        # 工具: FunUI
        ss.subspec 'FunUI' do |item|
            # FunUI路径
            item.source_files = 'Sources/FunUI/**/*'
            # FunUI依赖
#            item.dependency 'FunBox/Core'
        end
        
        # 工具: RxFunBox
        ss.subspec 'RxFunBox' do |item|
            # RxFunBox路径
            item.source_files = 'Sources/RxFunBox/**/*'
            # RxFunBox依赖
#            item.dependency 'FunBox/Core'
            item.dependency 'RxDataSources', '~> 4.0.1'
            item.dependency 'RxSwift', '~> 5.1.1'
            item.dependency 'RxCocoa', '~> 5.1.1'
        end
        
        # 工具: FunWebImage
        ss.subspec 'FunWebImage' do |item|
            # MediaHelper路径
            item.source_files = 'Sources/FunWebImage/**/*'

            # MediaHelper依赖
#            item.dependency 'FunBox/Core'
            item.dependency 'Kingfisher', '~> 5.15.0'
#            s.dependency 'KingfisherWebP', '~> 1.0.0'
        end
        
        # 工具: FunScan
        ss.subspec 'FunScan' do |item|
            # FunScan路径
            item.source_files = 'Sources/FunScan/Code/**/*'

            # FunScan依赖
#            item.dependency 'FunBox/Core'
            item.resource_bundles = {
                'FunScan' => ['Sources/FunScan/Assets/**/*.{storyboard,xib,xcassets,json,imageset,png,js,gif,md,strings}']
            }
            item.dependency 'FunBox/Modules/FunUI'
#            s.dependency 'Kingfisher', '~> 5.15.0'
#            s.dependency 'KingfisherWebP', '~> 1.0.0'
        end
        
        # 工具: FunMediaHelper
        ss.subspec 'FunMediaHelper' do |item|
            # MediaHelper路径
            item.source_files = 'Sources/FunMediaHelper/Code/**/*'
            # MediaHelper的Bundle地址
            item.resource_bundles = {
                'MediaHelper' => ['Sources/FunMediaHelper/Assets/**/*.{storyboard,xib,xcassets,json,imageset,png,gif,md,strings}']
            }
            # MediaHelper依赖
#            item.dependency 'FunBox/Core'
            item.dependency 'FunBox/Modules/FunWebImage'
            item.dependency 'FunBox/Modules/FunUI'
            item.dependency 'JXPhotoBrowser', '~> 3.1.2'
            item.dependency 'TZImagePickerController', '3.4.8'
        end
        
        
        
    end

end
