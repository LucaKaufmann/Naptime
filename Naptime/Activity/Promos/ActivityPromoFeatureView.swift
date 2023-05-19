//
//  ActivityPromoFeatureView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.5.2023.
//

import SwiftUI
import ComposableArchitecture

struct ActivityPromoFeatureView: View {
    
    let store: StoreOf<ActivityPromoFeature>
    
    var body: some View {
        NavigationView {
            ScrollView {
                IfLetStore(
                    store.scope(state: \.liveActivity,
                                action: ActivityPromoFeature.Action.liveActivityPromo),
                    then: { store in
                        LiveActivityPromoView(store: store)
                    }, else: { Text("Nothing here") }
                )
                
            }
//            .background(
////                Color("slate").edgesIgnoringSafeArea(.all)
//            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("**What's new?**")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        ViewStore(store).send(.dismissTapped)
                    }, label: {
                        Text("Done")
                    })
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct LiveActivityPromoView: View {
    
    let store: StoreOf<LiveActivityPromoFeature>
    
    @State var showLiveAction = false
    
    var body: some View {
        VStack {
            Image("live_activity_promo")
            Text("Live activities are now supported and can be enabled to show up on the lockscreen. (This can be changed later in the settings)")
                .padding(.horizontal)
            SettingsToggleRowView(label: "Show on lockscreen", setting: $showLiveAction)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("slate"))
                )
                .padding()
            Button(action: {
                ViewStore(store).send(.dismissTapped)
            }, label: {
                Text("Maybe later")
            })
        }
    }
}

struct ActivityPromoFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPromoFeatureView(store: Store(initialState: ActivityPromoFeature.State(id: UUID()), reducer: ActivityPromoFeature()))
    }
}
