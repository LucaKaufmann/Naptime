//
//  LabelledFormView.swift
//  EasyMQTT
//
//  Created by Luca Kaufmann on 7.3.2021.
//  Copyright © 2021 mqtthings. All rights reserved.
//

import SwiftUI

struct LabelledFormView<Content: View>: View {

    let content: Content
    var labelText: String

    init(label: String = "Label", @ViewBuilder content: () -> Content) {
        self.content = content()
        self.labelText = label
    }

    var body: some View {
        HStack {
            Text(labelText).font(.headline)
            Spacer()
            self.content
        }
    }
}

