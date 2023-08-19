//
//  SettingsView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import SwiftUI
import ComposableArchitecture
import CloudKit
import DesignSystem

struct SettingsView: View {
    
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
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
            .sheet(
                store: self.store.scope(state: \.$shareSheet, action: SettingsFeature.Action.shareSheet)
                ) { store in
                    shareView(share: viewStore.share)
                }
            .scrollContentBackground(.hidden)
            .background {
                Color("slate")
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)

//        .toolbarBackground(Color("ocean"))
    }
    
    /// Builds a `CloudSharingView` with state after processing a share.
    private func shareView(share: CKShare?) -> CloudKitShareView? {
        guard let share else {
            return nil
        }
        
        return CloudKitShareView(share: share)
    }
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
            }).accentColor(Color("sand"))
        }
    }
}
