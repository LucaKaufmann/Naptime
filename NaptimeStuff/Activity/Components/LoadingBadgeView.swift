//
//  LoadingBadgeView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 21.4.2023.
//

import SwiftUI

struct LoadingBadgeView: View {
    
    let title: String
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill()
            .foregroundColor(color)
            .overlay(
                ProgressView(title)
            )
    }
}

struct LoadingBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingBadgeView(title: "Loading", color: Color("slate"))
            .frame(width: 120, height: 80)
    }
}
