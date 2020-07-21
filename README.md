# FunBox

[![CI Status](https://img.shields.io/travis/xiaohua/FunBox.svg?style=flat)](https://travis-ci.org/xiaohua/FunBox)
[![Version](https://img.shields.io/cocoapods/v/FunBox.svg?style=flat)](https://cocoapods.org/pods/FunBox)
[![License](https://img.shields.io/cocoapods/l/FunBox.svg?style=flat)](https://cocoapods.org/pods/FunBox)
[![Platform](https://img.shields.io/cocoapods/p/FunBox.svg?style=flat)](https://cocoapods.org/pods/FunBox)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

FunBox is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FunBox'
```

## Author

xiaohua, choarkinphe@outlook.com

## FunBox说明书

### 什么是FunBox？

* 直接翻译，他是个“有趣的盒子”，方便我们调用一些系统功能，同时也提供些便捷性的工具，让开发效率有效提高
* 谐译一波，饭盒？ 我们iOSer的吃饭工具？

### 接下来是一个简单的演示

> 项目中经常需要弹窗选择，代码臃肿

```swift
let alertController = UIAlertController.init(title: "title", message: "message", preferredStyle: .alert)

let action = UIAlertAction.init(title: "title", style: .default) { (action) in
// do
}

// ...
present(alertController, animated: true) {

}  
```

> 以下是使用FunBox添加

```swift
FunBox.alert // FunBox.alert 本质是快速调取FunBox.Alert.default.style(.alert)
            .title(title: "title") // 需要标题就设置标题，不需要可以直接.message
            .titleColor(titleColor: .red) // 支持定义title、message的字体与颜色
            .titleFont(titleFont: UIFont.systemFont(ofSize: 18))
            .message(message: "message")
            .addAction(title: "No", style: .cancel) // 事件可以随意添加
            .addAction(title: "Yes", style: .default) { (action) in
        
            }
            .present() // 生成完后present弹出
```

> 同理，可以生成一个sheet

```swift
FunBox.Alert.default
            .style(.actionSheet) 
            .title(title: "title") // 需要标题就设置标题，不需要可以直接.message
            .titleColor(titleColor: .red) // 支持定义title、message的字体与颜色
            .titleFont(titleFont: UIFont.systemFont(ofSize: 18))
            .message(message: "message")
            .addActionTitles(titles: ["1","2","3"], handler: { (action) in
  
            }) // 支持直接以数组的方式插入（Alert也可）
            .addAction(title: "No", style: .cancel) // 事件可以随意添加
            .addAction(title: "Yes", style: .default) { (action) in
  
            }
            .present() // 生成完后present弹出
```

#### 什么？ 觉得用UIAlert生成的sheet还不够刺激？

> 这里还有基于UITableView的sheet选择器

```swift
FunBox.Sheet.default
            .tintColor(.orange) // 设置主题颜色
            .addAction("第一条") // 添加选项，可以直接是String也可以是Action实例，或者任何FunSheetActionConvertible协议的实体
            .addAction(FunBox.Sheet.Action(title: "第二条", value: "2", style: .default))
            .addActions(["第三条","第四条"]) // 多条添加本质与单挑一致
            .handler { (action) in // 单选的回调，多选走另外一个回调
    
            }
            .selectType(.single) // 单选多选
            .contentInsets(UIEdgeInsets.init(top: 12, left: 8, bottom: 12, right: 8)) // 支持设置内边距
            .selectImage(UIImage(named: "123")!) // 可以设置checkBox的样式图片
            .normalImage(UIImage(named: "123")!)
            .present()
```

#### 同理，我们可以来个DatePicker

> 系统原生方法我在这就不写了，节(懒)约(癌)篇(晚)幅(期)

```swift
FunBox.datePicker
        .setDate(date: "2020/01/23") // 首先设置好武汉的封城日期
        .setDate(date: Date(timeIntervalSinceReferenceDate: 123456), animated: true) // setDate支持直接字符串，也可以Date对象，或者自行创建支持FunDateConvertable协议的任何实例
        .dateFormatter("yyyy/MM/dd") // 转换全靠它了，请认真对待
        .dateHandler { (date, formatter) in
        
        }
        .present()
```

> 以上是我们常用到的弹窗选择，能覆盖到很多场景了

#### 关于Toast

> Hud视图可能在项目中运用就更广泛了

## License

FunBox is available under the MIT license. See the LICENSE file for more info.
