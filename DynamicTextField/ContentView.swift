
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
