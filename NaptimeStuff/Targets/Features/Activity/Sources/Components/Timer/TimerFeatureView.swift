//
//  TimerFeatureView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 16.2.2023.
//

import SwiftUI
import ComposableArchitecture

struct TimerFeatureView: View {
    
    let store: StoreOf<TimerFeature>
    
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
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                Text("\(label) \(formatter.string(from: interval) ?? "")")
                    .font(Font.system(size: fontSize, design: fontDesign))
            }
            .onReceive(timer) { _ in
                if viewStore.isTimerRunning {
                    interval = Date().timeIntervalSince(viewStore.startDate ?? Date())
                }
            }
        }
        
    }
}

struct TimerFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        TimerFeatureView(store: Store(initialState: TimerFeature.State(startDate: Date(),
                                                                       isTimerRunning: true),
                                      reducer: TimerFeature()))
    }
}
