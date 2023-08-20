//
//  AwakeRow.swift
//  Naptime
//
//  Created by Luca Kaufmann on 1.2.2023.
//

import SwiftUI
import NaptimeKit
import DesignSystem

struct AwakeRow: View {
    
    let interval: TimeInterval
    
    var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()
    
    var body: some View {
        ZStack {
            NaptimeDesignColors.sandLight
                .offset(x: 34)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                )
            HStack {
                Rectangle()
                    .fill(NaptimeDesignColors.sandLight)
                    .frame(width: 4, alignment: .center)
                    .offset(x: 34)
                Spacer()
                    .frame(width: 50)
                    .padding(.trailing)
                Text("Awake for \(formatter.string(from: abs(interval)) ?? "")")
                    .foregroundColor(NaptimeDesignColors.sand)
                Spacer()
            }
        }.frame(height: scaleNumber(abs(interval), fromMin: 0, fromMax: 86400, toMin: 20, toMax: 500))
    }
}

struct AwakeRow_Previews: PreviewProvider {
    static var previews: some View {
        AwakeRow(interval: 1000)
    }
}
