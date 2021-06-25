#  HZEditor 使用说明

### 先上一组实例

```swift
HZEditor.default
    .feed(options: [.imageCount(4),.textCount(500)]) // 喂各种配置信息
    .feed(content: content) // 喂内容信息（任意类型遵守HZEditContentable协议就行）<编辑模式下传>
    .response(type: TextContent.self, navigation: { (navigation) in // 弹出
        
        // 回调的navigation包括content（HZEditContentable协议，有text和medias的对象）
        print(navigation.content)
        // 拿到content后，在这里调用接口上传提交数据
        
        // 接口调用成功后，
        // 执行 # navigation.dismiss(true) 就会收回HZEditor页面
        // navigation.dismiss(false) 回重新点亮提交按钮，不会收回
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
        // 模拟请求2s后完成
            navigation.dismiss(true)
        }
    })
```



### 协议

1. HZEditContentable

   ```swift
   // 实际业务中承载内容的模型需要遵守该协议
   public protocol HZEditContentable {
       var text: String? { get set } // 需要展示的文本内容
       var medias: [HZEditorImage]? { get set } // 需要展示的图片
       init()
   }
   ```

   

2. HZEditorImage

   ```swift
   // 媒体资源的协议<实际业务中，承载媒体资源信息的模型遵守该协议>
   public protocol HZEditorImage: PickResource {
       var url: String? { get set }
   }
   public protocol PickResource {
       var image: UIImage? { get set }
       var asset: PHAsset? { get set }
       init()
   }
   ```

3. 创建

   使用`HZEditor.default`即可创建基本样式的Editor,`present`即可直接使用

   ```swift
   HZEditor.default
       .response(type: TextContent.self, navigation: { (navigation) in // 弹出
           
       })
   ```

   

   #### 如果需要自定义

   > 可效仿default的方式，extension一个，自行设置好各种默认值

   ```swift
   extension HZEditor {   
       // 默认类
       public static var `default`: HZEditor {
           let instance = HZEditor()
           return instance
       }
   }
   ```

   > 设置Options: `feed(options: HZEditorConfigOptions)` [方便后期各种配置化的拓展]

   ```swift
   // 分别设置允许最多照片、最多文字数
   HZEditor.default
       .feed(options: [.imageCount(4),.textCount(500)]) // 喂各种配置信息
       .response(type: TextContent.self, navigation: { (navigation) in // 弹出
           
       })
   ```

4. 编辑模式

   > 创建完成后，使用`feed(content: HZEditContentable?)`方法，设置数据

   ```swift
   // 前文中说过HZEditContentable协议，所以此时只需要传入项目中使用似的Model
   HZEditor.default
       .feed(content: content)
       .response(type: TextContent.self, navigation: { (navigation) in // 弹出
   
       })
   ```

   

5. 指定返回类型

   > HZEditor并不知道你业务中具体使用模型的类型是什么，所以，在response时，需要制定类型

   ```swift
   // 前文中说过HZEditContentable协议，所以此时只需要传入项目中使用似的Model
   HZEditor.default
       .feed(content: content)
       .response(type: TextContent.self, navigation: { (navigation) in // 弹出<这里的TextContent就是你项目中用来承载输入内容的模型>
   
       })
   ```

   