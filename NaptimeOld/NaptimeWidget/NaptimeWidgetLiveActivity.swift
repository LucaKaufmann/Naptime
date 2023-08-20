//
//  NaptimeWidgetLiveActivity.swift
//  NaptimeWidget
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

enum NaptimeActivityState: String, Codable {
    case asleep = "Asleep"
    case awake = "Awake"
}

struct NaptimeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startDate: Date
        var activityState: NaptimeActivityState
        
        var iconName: String {
            return activityState == .asleep ? "bed.double.circle" : "sun.max"
        }
        
        var titleIconName: String {
            return activityState == .asleep ? "powersleep" : "sun.and.horizon"
        }
    }

    // Fixed non-changing properties about your activity go here!
    var id: UUID
}

@available(iOS 16.2, *)
struct NaptimeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NaptimeWidgetAttributes.self) { context in
            NaptimeWidgetLiveContentView(contentState: context.state)
                } dynamicIsland: { context in
                    DynamicIsland {
                        DynamicIslandExpandedRegion(.leading) {
                            VStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color("ocean"))
                                    .frame(width: 4, alignment: .center)
                                Image(systemName: context.state.iconName)
                                    .resizable()
                                    .foregroundColor(Color("slateInverted"))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                           .fill(Color("slate"))
                                    )
                                Rectangle()
                                    .fill(Color("ocean"))
                                    .frame(width: 4, alignment: .center)
                            }
                            .padding(.leading)

                            .background(
                                Color("sandLight")
                                    .offset(x: -20)
                                    .opacity(context.state.activityState == .asleep ? 1 : 0)
                            )
                        }
                        DynamicIslandExpandedRegion(.center) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: context.state.titleIconName)
                                    Text("\(formatDate(context.state.startDate))")
                                }.foregroundColor(Color("sand"))
                                .font(.headline)
                                HStack(spacing: 0) {
                                    Text("\(context.state.activityState.rawValue) for ")
                                    Text(timerInterval: context.state.startDate...Date(timeInterval: 12 * 60*60, since: .now), countsDown: false)
                                        
                                }.font(.footnote.monospacedDigit())
                                    .foregroundColor(Color("slateInverted"))
                                
                            }
                            .padding(.horizontal)
                        }
                        DynamicIslandExpandedRegion(.trailing) {
                            Text("Naptime")
                                .font(.footnote)
                                .foregroundColor(Color("slateInverted"))
                        }
                    } compactLeading: {
                        HStack {
                            Image(systemName: context.state.titleIconName)
                                .foregroundColor(Color("sandLight"))
                            Text("Naptime")
                                .font(.footnote)
                        }
                    } compactTrailing: {
                        Text(timerInterval: context.state.startDate...Date(timeInterval: 12 * 60*60, since: .now), countsDown: false)
                    } minimal: {
                        Image(systemName: context.state.iconName)
                            .foregroundColor(Color("sandLight"))
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
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = calendar.isDateInToday(date) ? "HH:mm" : "E HH:mm"
        return dateFormatter.string(from: date)
    }
}

@available(iOS 16.2, *)
struct NaptimeWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = NaptimeWidgetAttributes(id: UUID())
    static let asleepState = NaptimeWidgetAttributes.ContentState(startDate: Date(), activityState: .asleep)
    static let awakeState = NaptimeWidgetAttributes.ContentState(startDate: Date(), activityState: .awake)

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
            .previewContext(asleepState, viewKind: .content)
            .previewDisplayName("Notification")
        attributes
            .previewContext(awakeState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
