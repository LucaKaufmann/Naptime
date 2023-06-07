//
//  NaptimeWidgetLiveContentView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 18.5.2023.
//

import SwiftUI

struct NaptimeWidgetLiveContentView: View {
    
    
    let contentState: NaptimeWidgetAttributes.ContentState
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color("ocean"))
                    .frame(width: 4, alignment: .center)
                Image(systemName: contentState.iconName)
                    .resizable()
                    .foregroundColor(Color("slateInverted"))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color("slate")
                                .opacity(contentState.activityState == .asleep ? 1 : 0.5)
)
                    )
                Rectangle()
                    .fill(Color("ocean"))
                    .frame(width: 4, alignment: .center)
            }
            .padding(.leading)

            .background(
                Color(contentState.activityState == .asleep ? "sandLight" : "oceanLight")
                    .offset(x: -20)
//                    .opacity(contentState.activityState == .asleep ? 1 : 0)
            )
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: contentState.titleIconName)
                    Text("\(formatDate(contentState.startDate))")
                    Spacer()
                    Text("Naptime")
                        .font(.footnote)
                        .foregroundColor(Color("slateInverted"))
                }.foregroundColor(Color("sand"))
                .font(.headline)
                HStack(spacing: 0) {
                    Text("\(contentState.activityState.rawValue) for ")
                    Text(timerInterval: contentState.startDate...Date(timeInterval: 12 * 60*60, since: .now), countsDown: false)
                        
                }.font(.footnote.monospacedDigit())
                    .foregroundColor(Color("slateInverted"))
                
            }.padding(.horizontal)
            Spacer()
        }
        .background(
            Color(contentState.activityState == .asleep ? "ocean" : "oceanLight")
                .offset(x: 34)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                )
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = calendar.isDateInToday(date) ? "HH:mm" : "E HH:mm"
        return dateFormatter.string(from: date)
    }
}

struct NaptimeWidgetLiveContentView_Previews: PreviewProvider {
    static var previews: some View {
        NaptimeWidgetLiveContentView(contentState: .init(startDate: Date(), activityState: .awake))
        NaptimeWidgetLiveContentView(contentState: .init(startDate: Date(), activityState: .asleep))
    }
}
