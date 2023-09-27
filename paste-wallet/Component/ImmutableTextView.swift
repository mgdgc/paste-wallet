//
//  TextViewWrapper.swift
//  paste-wallet
//
//  Created by 최명근 on 9/27/23.
//

import Foundation
import UIKit
import SwiftUI

struct ImmutableTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        var textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 17)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
