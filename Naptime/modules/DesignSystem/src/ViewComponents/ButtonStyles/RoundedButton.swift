//
//  BlueButton.swift
//  PuppySleepTracker
//
//  Created by Luca Kaufmann on 16.8.2021.
//

import SwiftUI

struct RoundedButton: ButtonStyle {
    
    let backgroundColor: Color
    let backgroundOpacity: Double
    let cornerRadius: Double
    
    init(backgroundColor: Color, backgroundOpacity: Double = 1.0, cornerRadius: Double) {
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(backgroundColor.opacity(backgroundOpacity))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
