//
//  NaptimeWidgetLiveActivity.swift
//  NaptimeWidget
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NaptimeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var startDate: Date
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

@available(iOS 16.2, *)
struct NaptimeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NaptimeWidgetAttributes.self) { context in
            NaptimeWidgetLiveContentView(startDate: context.state.startDate)
                } dynamicIsland: { context in
                    DynamicIsland {
                        DynamicIslandExpandedRegion(.leading) {
                            Text("Context")
                        }
                    } compactLeading: {
                        Image(systemName: "circle")
                            .foregroundColor(.green)
                    } compactTrailing: {
                        Text("Context")
                    } minimal: {
                        Image(systemName: "circle")
                            .foregroundColor(.green)
                    }
                }
//        ActivityConfiguration(for: NaptimeWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text(timerInterval: context.state.startDate...Date(timeInterval: 12 * 60, since: .now))
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                DynamicIslandExpandedRegion(.leading) {
//                                    Label("Pizzas", systemImage: "bag")
//                                        .foregroundColor(.indigo)
//                                        .font(.title2)
//                                }
//            } compactLeading: {
//                Text("asd")
//            } compactTrailing: {
//                Text("asd")
//            } minimal: {
//                Text("Minimal")
//            }
//        }
    }
}

@available(iOS 16.2, *)
struct NaptimeWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = NaptimeWidgetAttributes(name: "Me")
    static let contentState = NaptimeWidgetAttributes.ContentState(startDate: Date())

    static var previews: some View {
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
