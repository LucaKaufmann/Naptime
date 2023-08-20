//
//  NaptimeWidgetBundle.swift
//  NaptimeWidget
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import WidgetKit
import SwiftUI

@main
struct NaptimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        NaptimeWidget()
        NaptimeWidgetLiveActivity()
    }
}
