//
//  TimerView.swift
//  NapTime
//
//  Created by Luca Kaufmann on 18.8.2021.
//

import SwiftUI

struct TimerView: View {
    
    var label: String = ""
    var fontSize: CGFloat = 12
    var fontDesign: Font.Design = .monospaced
    
    @State var isTimerRunning = false
    @State var startTime =  Date()
    @State private var interval = TimeInterval()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()
    
    var body: some View {
        Text("\(label) \(formatter.string(from: interval) ?? "")")
            .font(Font.system(size: fontSize, design: fontDesign))
            .onReceive(timer) { _ in
                if self.isTimerRunning {
                    interval = Date().timeIntervalSince(startTime)
                }
            }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
