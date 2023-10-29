//
//  SettingsView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import SwiftUI
import ComposableArchitecture
import CloudKit

#if os(macOS) || os(iOS) || os(tvOS)
import NaptimeKit
import DesignSystem
#elseif os(watchOS)
import NaptimeKitWatchOS
import DesignSystemWatchOS
#endif

public struct SettingsView: View {
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    let store: StoreOf<SettingsFeature>
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    SettingsToggleRowView(label: "Show asleep live activity", setting: viewStore.$showAsleepLiveAction)
                    SettingsToggleRowView(label: "Show awake live activity", setting: viewStore.$showAwakeLiveAction)
                }
                Section {
                    SettingsButtonRowView(store: store, label: "Share with others", systemIcon: "square.and.arrow.up")
                }
            }
            #if !os(watchOS)
            .sheet(
                store: self.store.scope(state: \.$shareSheet, action: SettingsFeature.Action.shareSheet)
                ) { store in
                    shareView(share: viewStore.share)
                }
            #endif
            .scrollContentBackground(.hidden)
            .background {
                NaptimeDesignColors.slate.ignoresSafeArea()
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)

//        .toolbarBackground(Color("ocean"))
    }
    
    #if !os(watchOS)
    /// Builds a `CloudSharingView` with state after processing a share.
    private func shareView(share: CKShare?) -> CloudKitShareView? {
        guard let share else {
            return nil
        }
        
        return CloudKitShareView(share: share)
    }
    #endif
}

struct SettingsButtonRowView: View {
    
    let store: StoreOf<SettingsFeature>
    
    let label: String
    let systemIcon: String?
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button(action: {
                viewStore.send(.shareTapped)
            }, label: {
                HStack {
                    if let systemIcon {
                        Image(systemName: systemIcon)
                    }
                    Text(label)
                }
            }).accentColor(NaptimeDesignColors.sand)
        }
    }
}
