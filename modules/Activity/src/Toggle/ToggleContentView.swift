//
//  ToggleContentView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.1.2023.
//

import SwiftUI
#if os(macOS) || os(iOS) || os(tvOS)
import DesignSystem
#elseif os(watchOS)
import DesignSystemWatchOS
#endif

struct ToggleContentView: View {
    
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isOn ? "sleep" : "powersleep")
                .resizable()
                .frame(width: 20, height: 20)
            Text(isOn ? "Wake up" : "Sleep")
        }.foregroundColor(.white)
    }
}

struct ToggleContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToggleContentView(isOn: Binding.constant(true))
            ToggleContentView(isOn: Binding.constant(false))
        }.background(NaptimeDesignColors.ocean)
    }
}
