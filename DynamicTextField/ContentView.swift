//
//  ContentView.swift
//  DynamicTextField
//
//  Created by 王庭志 on 2024/6/19.
//

import SwiftUI

struct ContentView: View {
    @State private var textViewSize = TextViewSize()
    var body: some View {
        DynamicTextView(maxWidth: 300)
            .frame(width: textViewSize.size.width, height: textViewSize.size.height)
            .environment(textViewSize)
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
    }
}

struct DynamicTextView: UIViewRepresentable {
    @Environment(TextViewSize.self) private var textViewSize: TextViewSize?
    
    var minWidth: CGFloat = 100
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 19)
        view.text = "Type something"
        view.textColor = .black.withAlphaComponent(0.3)
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        textViewSize?.size.height = view.contentSize.height
        textViewSize?.size.width = max(view.contentSize.width, minWidth)
        view.isEditable = true
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicTextView
        init(_ parent: DynamicTextView) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .black
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let textViewSize = textView.contentSize
            let sizeThatFited = textView.sizeThatFits(CGSize(width: parent.maxWidth ?? .infinity, height: parent.maxHeight ?? textViewSize.height))
            parent.textViewSize?.size = CGSize(
                width: min(max(parent.minWidth, sizeThatFited.width), (parent.maxWidth ?? sizeThatFited.width)),
                height: sizeThatFited.height
            )
        }
    }
}

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
