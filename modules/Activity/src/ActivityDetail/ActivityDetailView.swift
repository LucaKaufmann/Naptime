//
//  ActivityEditView.swift
//  PuppySleepTracker
//
//  Created by Luca Kaufmann on 17.8.2021.
//

import SwiftUI
import ComposableArchitecture

#if os(macOS) || os(iOS) || os(tvOS)
import NaptimeKit
import DesignSystem
#elseif os(watchOS)
import NaptimeKitWatchOS
import DesignSystemWatchOS
#endif

struct ActivityDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var startDate: Date?
    @State var endDate: Date?
    
    let store: Store<ActivityDetail.State, ActivityDetail.Action>
    
    init(store: Store<ActivityDetail.State, ActivityDetail.Action>) {
        self.store = store
    }
            
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Form {
                Section {
                    HStack {
                        if startDate != nil {
                            Text("Start Time")
                            Spacer()
                            DatePicker(selection: Binding<Date>(get: {self.startDate ?? Date()}, set: {self.startDate = $0}), in: ...Date(), displayedComponents: .date) {
                                            EmptyView()
                                        }
                            DatePicker(selection: Binding<Date>(get: {self.startDate ?? Date()}, set: {self.startDate = $0}), in: ...Date(), displayedComponents: .hourAndMinute) {
                                            EmptyView()
                                        }
                        } else {
                            Text("Start Time")
                            Spacer()
                            Text("-")
                                .onTapGesture {
                                    startDate = Date()
                                }
                        }
                    }
                    VStack(alignment: .trailing) {
                        HStack {
                            if endDate != nil {
                                Text("End Time")
                                Spacer()
                                DatePicker(selection: Binding<Date>(get: {self.endDate ?? Date()}, set: {self.endDate = $0}), in: ...Date(), displayedComponents: .date) {
                                    EmptyView()
                                }
                                DatePicker(selection: Binding<Date>(get: {self.endDate ?? Date()}, set: {self.endDate = $0}), in: ...Date(), displayedComponents: .hourAndMinute) {
                                    EmptyView()
                                }

                            } else {
                                Text("End Time")
                                Spacer()
                                Text("-")
                                    .onTapGesture {
                                        endDate = Date()
                                    }
                            }
                        }
                        if endDate != nil {
                            Button("Clear") {
                                endDate = nil
                            }
                        }
                    }
                }
                Section {
                    Button("Delete") {
                        guard let activity = viewStore.activity else {
                            return
                        }
                        viewStore.send(.deleteActivity(activity))
                        
                        presentationMode.wrappedValue.dismiss()
                    }.foregroundColor(.red)
                }
                Section {
                    Button("Save") {
                        guard let activity = viewStore.activity else {
                            return
                        }
                        
                        var updatedActivity = activity
                        updatedActivity.startDate = startDate ?? Date()
                        updatedActivity.endDate = endDate
                        viewStore.send(.updateActivity(updatedActivity))
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .background {
                NaptimeDesignColors.slate
            }
            .onAppear {
                self.startDate = viewStore.activity?.startDate ?? Date()
                self.endDate = viewStore.activity?.endDate
            }
        }
    }
    
    func save() {
//        guard let activity = viewModel.activity else {
//            return
//        }
//
//        activity.date = viewModel.date
//        activity.endDate = viewModel.endDate
//        activity.activityType = viewModel.activityType
//
//        try? viewContext.save()
    }
    
    func delete() {
//        guard let activity = viewModel.activity else {
//            return
//        }
//
//        try? viewContext.delete(activity)
    }
}

struct ActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let activity = ActivityModel(id: UUID(), startDate: Date(), endDate: Date(), type: .sleep)
        ActivityDetailView(
            store: Store(
                initialState: ActivityDetail.State(id: activity.id, activity: activity)) { ActivityDetail()
                })
    }
}
