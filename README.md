# 动态大小的text field

灵感来自 https://www.youtube.com/watch?v=rmCvCic6Kv8

我在它的基础上增加了横向宽度的动态变化。

## 思路解释：
动态大小的text field需要依赖UIKit中的UITextView来实现，因为SwiftUI原生的TextField以及TextEditor都无法很好地实现这一想法。

然后是利用UITextView的代理来监听文字输入，在textViewDidChange事件中获取正确的TextView大小，然后通过SwiftUI的Environment将数据传递出去。

值得注意的是，原视频中是使用UITextView的contentSize来获取实际高度，这是因为UITextView继承自UIScrollView，所以当它的文本超过其高度时，它会自动换行，使得ContentSize变化。

但是对于宽度的获取就没有这么容易，由于UITextView的宽度不会随输入的变化而变化，所以通过contentSize获取宽度是不可行的。最终让我找到UIView上sizeThatFits这个方法，这个方法可以根据传入的尺寸限制来计算view实际需要的尺寸，通过这个方法就可以获得较为正确的宽高。

然后将宽高通过environment传递回上层，最终通过swiftUI的frame装饰器来设置TextField的宽高。

这里还有一个问题，我一开始尝试使用Binding来传递数据，发现在首次渲染的时候，Binding的值没有被正确修改，最后不得已只能采用Environment来传递数据。

## 代码解释

``` swift

import SwiftUI
// 容器View，后续需要封装成可用的容器
struct ContentView: View {
    // 数据传递使用
    @State private var textViewSize = TextViewSize()
    var body: some View {
        DynamicTextView(maxWidth: 300) // 自定义对象
            .frame(width: textViewSize.size.width, height: textViewSize.size.height) // 设置frame
            .environment(textViewSize) // 通过environment传递数据
            // 以下是简单装饰
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
    }
}

struct DynamicTextView: UIViewRepresentable {
    @Environment(TextViewSize.self) private var textViewSize: TextViewSize?
    // 最大最小宽高限制，最小高度不需要
    var minWidth: CGFloat = 100
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?
    
    // 创建Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 创建UITextView
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 19)
        view.text = "Type something"
        view.textColor = .black.withAlphaComponent(0.3)
        view.backgroundColor = .clear
        view.delegate = context.coordinator // 绑定代理
        textViewSize?.size.height = view.contentSize.height // 设置初始高度
        textViewSize?.size.width = max(view.contentSize.width, minWidth) // 设置初始宽度
        view.isEditable = true
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicTextView // 绑定parent，方便取数据，同时这种方式修改parent的值不会导致引用丢失
        init(_ parent: DynamicTextView) {
            self.parent = parent
        }
        
        // 开始编辑时，去除placeholder
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .black
        }
        
        // 监听文本输入
        func textViewDidChange(_ textView: UITextView) {
            let textViewSize = textView.contentSize // 获取contentSize
            // 获取sizeThatFit的尺寸
            let sizeThatFited = textView.sizeThatFits(CGSize(width: parent.maxWidth ?? .infinity, height: parent.maxHeight ?? textViewSize.height))
            // 设置值，限制最大值和最小值
            parent.textViewSize?.size = CGSize(
                width: min(max(parent.minWidth, sizeThatFited.width), (parent.maxWidth ?? sizeThatFited.width)),
                height: sizeThatFited.height
            )
        }
    }
}

// 用于数据传递
@Observable
class TextViewSize {
    var size: CGSize
    init(_ size: CGSize = .zero) {
        self.size = size
    }
}
        
#Preview {
    ContentView()
}

```

代码本身还算是简单，关键在于思考过程。