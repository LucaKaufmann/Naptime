//
//  NaptimeWidgetLiveContentView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 18.5.2023.
//

import SwiftUI

struct NaptimeWidgetLiveContentView: View {
    
    let startDate: Date
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color("ocean"))
                    .frame(width: 4, alignment: .center)
                Image(systemName: "bed.double.circle")
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
                Color("sandLight").offset(x: -20)
            )
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "powersleep")
                    Text("\(formatDate(startDate))")
                    Spacer()
                    Text("Naptime")
                        .font(.footnote)
                        .foregroundColor(Color("slateInverted"))
                }.foregroundColor(Color("sand"))
                .font(.headline)
                    Text(timerInterval: startDate...Date(timeInterval: 12 * 60*60, since: .now), countsDown: false)
                    .foregroundColor(Color("slateInverted"))
                
            }.padding(.horizontal)
            Spacer()
//            Image(systemName: "chevron.right")
        }
        .background(
            Color("ocean")
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
        NaptimeWidgetLiveContentView(startDate: Date())
    }
}
