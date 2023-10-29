//
//  WatchActivityButtonsView.swift
//  WatchApp
//
//  Created by Luca on 29.10.2023.
//

import SwiftUI
import ComposableArchitecture
import NaptimeKitWatchOS
import DesignSystemWatchOS
import ActivityWatchOS

struct WatchActivityButtonsView: View {
    
    let store: Store<WatchActivityFeature.State, WatchActivityFeature.Action>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ToggleView(isOn: viewStore.$isSleeping) {
                Color.clear
                    .overlay(
                        RoundedRectangle(cornerRadius: 12).strokeBorder(NaptimeDesignColors.slate, lineWidth: 5)
                        
                    )
            } button: {
                Group {
                    if viewStore.isSleeping  {
                        NaptimeDesignColors.tomatoLight
                    } else {
                        NaptimeDesignColors.ocean
                    }
                }
                .overlay(ToggleContentView(isOn: viewStore.$isSleeping))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            .shadow(color: NaptimeDesignColors.slateDark.opacity(0.2), radius: 2)
        }
    }
}
