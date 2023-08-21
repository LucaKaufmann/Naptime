//
//  SettingsRowViews.swift
//  DesignSystem
//
//  Created by Luca Kaufmann on 19.8.2023.
//

import Foundation
import SwiftUI

public struct SettingsToggleRowView: View {
    
    public init(label: String, setting: Binding<Bool>) {
        self.label = label
        self._setting = setting
    }
    
    let label: String
    @Binding var setting: Bool
    
    public var body: some View {
        HStack {
            Toggle(isOn: $setting, label: {
                Text(label)
            })
        }
    }
}
