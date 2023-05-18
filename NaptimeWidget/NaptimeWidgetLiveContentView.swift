//
//  NaptimeWidgetLiveContentView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 18.5.2023.
//

import SwiftUI

struct NaptimeWidgetLiveContentView: View {
    
    let startDate: Date
    
    @State var formatter: DateFormatter = {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
      }()
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color("ocean"))
                    .frame(width: 4, alignment: .center)
                Image(systemName: "bed.double.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                           .fill(Color("slate"))
                    )
                Rectangle()
                    .fill(Color("ocean"))
                    .frame(width: 4, alignment: .center)
            }
            VStack(alignment: .leading) {
                    Text("Asleep since \(formatter.string(from: startDate))")
                    Text(timerInterval: startDate...Date(timeInterval: 12 * 60*60, since: .now), countsDown: false)
                
            }.padding(.horizontal)
            Spacer()
//            Image(systemName: "chevron.right")
        }
        .padding(.horizontal)
        .background(
            Color("ocean")
                .offset(x: 34)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                )
        )
    }
}

struct NaptimeWidgetLiveContentView_Previews: PreviewProvider {
    static var previews: some View {
        NaptimeWidgetLiveContentView(startDate: Date())
    }
}
