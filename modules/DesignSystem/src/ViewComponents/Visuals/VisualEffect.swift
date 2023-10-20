//
//  VisualEffect.swift
//  Naptime
//
//  Created by Luca Kaufmann on 31.1.2023.
//

import SwiftUI

#if os(iOS)
public struct VisualEffectView: UIViewRepresentable {
    
    public init(effect: UIVisualEffect? = nil) {
        self.effect = effect
    }
    
    public var effect: UIVisualEffect?

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    public func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
#endif
