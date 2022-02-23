#
# Be sure to run `pod lib lint FunModules.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'FunModules'
    s.version          = '1.0.9'
    s.summary          = 'FunBox 外部组件库'
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
    
    # 组件库
    s.dependency 'FunBox/Core'#, '~> 1.0.9'

        
        # 工具: FunUI
        s.subspec 'FunUI' do |item|
            # FunUI路径
            item.source_files = 'Sources/FunUI/**/*'
        end
        
#        # 工具: RxFunBox
#        s.subspec 'RxFunBox' do |item|
#            # RxFunBox路径
#            item.source_files = 'Sources/RxFunBox/**/*'
#            # RxFunBox依赖
#            item.dependency 'FunBox/Box/UI', '~> 1.0.3'
#            item.dependency 'RxDataSources', '~> 4.0.1'
#            item.dependency 'RxSwift', '~> 5.1.1'
#            item.dependency 'RxCocoa', '~> 5.1.1'
#        end
        # 工具: RxFunBox
        s.subspec 'FunRefresher' do |item|
            # FunRefresher路径
            item.source_files = 'Sources/FunRefresher/**/*'
            # FunRefresher依赖
#            item.dependency 'FunBox/Fun', '~> 1.0.9'
#            item.dependency 'RxDataSources', '~> 4.0.1'
#            item.dependency 'RxSwift', '~> 5.1.1'
#            item.dependency 'RxCocoa', '~> 5.1.1'
        end
        
        # 工具: FunWebImage
        s.subspec 'FunWebImage' do |item|
            # MediaHelper路径
            item.source_files = 'Sources/FunWebImage/**/*'

            # MediaHelper依赖
            item.dependency 'Kingfisher', '~> 5.15.0'
#            s.dependency 'KingfisherWebP', '~> 1.0.0'
        end
        
        # 工具: FunScan
        s.subspec 'FunScan' do |item|
            # FunScan路径
            item.source_files = 'Sources/FunScan/Code/**/*'

            # FunScan依赖
            item.resource_bundles = {
                'FunScan' => ['Sources/FunScan/Assets/**/*.{storyboard,xib,xcassets,json,imageset,png,js,gif,md,strings}']
            }
            item.dependency 'FunModules/FunUI'
        end
        
        # 工具: FunMediaHelper
        s.subspec 'FunMediaHelper' do |item|
            # MediaHelper路径
            item.source_files = 'Sources/FunMediaHelper/Code/**/*'
            # MediaHelper的Bundle地址
            item.resource_bundles = {
                'MediaHelper' => ['Sources/FunMediaHelper/Assets/**/*.{storyboard,xib,xcassets,json,imageset,png,gif,md,strings}']
            }
            # MediaHelper依赖
            item.dependency 'FunModules/FunWebImage'
            item.dependency 'FunModules/FunUI'
            item.dependency 'JXPhotoBrowser', '~> 3.1.2'
            item.dependency 'TZImagePickerController', '3.4.8'
        end
        
    


end
