#  HZEditor 使用说明

### 先上一组实例

```swift
    // 配置样式 
    var style = HZScan.Style()
    style.boardColor = .blue
    HZScan.default
    .feed(style: style) // feed样式
    .response { (navigation) in
        // navigation.content 就是扫码的结果
        print(navigation.content)
        
        self.navigationController?.pushViewController(WebViewController(), animated: true)
        // dismiss(true) 就会收回扫码页面
        // dismiss(false) 就会重新开启扫码
        navigation.dismiss(true)

    }
```
