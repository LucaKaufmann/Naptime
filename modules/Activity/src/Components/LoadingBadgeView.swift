//
//  LoadingBadgeView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 21.4.2023.
//

import SwiftUI
#if os(macOS) || os(iOS) || os(tvOS)
import DesignSystem
#elseif (watchOS)
import DesignSystemWatchOS
#endif

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

//struct LoadingBadgeView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadingBadgeView(title: "Loading", color: NaptimeDesignColors.slate)
//            .frame(width: 120, height: 80)
//    }
//}
