//
//  SettingsView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import SwiftUI
import ComposableArchitecture
import CloudKit

struct SettingsView: View {
    
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                SettingsToggleRowView(label: "Show on lockscreen", setting: viewStore.binding(\.$showLiveAction))
                SettingsButtonRowView(store: store, label: "Share with others", systemIcon: "square.and.arrow.up")
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

struct SettingsToggleRowView: View {
    
    let label: String
    @Binding var setting: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: $setting, label: {
                Text(label)
            })
        }
    }
}

struct SettingsButtonRowView: View {
    
    let store: StoreOf<SettingsFeature>
    
    let label: String
    let systemIcon: String?
    
    var body: some View {
        Button(action: {
            ViewStore(store).send(.shareTapped)
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
