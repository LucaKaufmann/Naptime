
//  FormTextfield.swift
//  EasyMQTT
//
//  Created by Luca Kaufmann on 7.3.2021.
//  Copyright © 2021 mqtthings. All rights reserved.
//

import SwiftUI

struct FormTextField: View {

    @Binding var text: String
    @State var placeholder: String
    @State var multiLine: Bool = false

    var body: some View {
        if multiLine, #available(iOS 14.0, macOS 11.0, *) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    HStack {
                        Spacer()
                        Text(placeholder)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .opacity(0.6)
                            .padding(.trailing, 8)
                    }
                }
                #if os(macOS) || os(iOS) || os(tvOS)
                TextEditor(text: $text)
                    .multilineTextAlignment(.trailing)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.body)
                
                #endif
            }
        } else {
            TextField(placeholder, text: $text, onCommit: {
                print("end editing")
//                UIApplication.shared.endEditing()
            })
            #if !os(watchOS)
            .autocapitalization(.none)
            #endif
            .disableAutocorrection(true)
            .multilineTextAlignment(.trailing)
            .font(.body)
        }
    }
}
