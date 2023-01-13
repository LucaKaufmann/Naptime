//
//  ActivityEditView.swift
//  PuppySleepTracker
//
//  Created by Luca Kaufmann on 17.8.2021.
//

import SwiftUI
import ComposableArchitecture
import NapTimeData

struct ActivityDetailView: View {
    
    @State var startDate = Date()
    @State var endDate: Date?
    
    let store: Store<ActivityDetail.State, ActivityDetail.Action>
            
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Form {

                Section {
                    DatePicker(selection: $startDate, in: ...Date(), displayedComponents: .hourAndMinute) {
                                    Text("Start time")
                                }
                    HStack {
                        if endDate != nil {
                            DatePicker(selection: Binding<Date>(get: {self.endDate ?? Date()}, set: {self.endDate = $0}), in: ...Date(), displayedComponents: .hourAndMinute) {
                                            Text("End time")
                                        }
                            Button("Clear") {
                                endDate = nil
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
                }
                Section {
                    Button("Delete") {
                        viewStore.send(.deleteActivity)
                    }.foregroundColor(.red)
                }
                Section {
                    Button("Save") {
                        guard let activity = viewStore.activity else {
                            return
                        }
                        
                        var updatedActivity = activity
                        updatedActivity.startDate = startDate
                        updatedActivity.endDate = endDate
                        viewStore.send(.updateActivity(updatedActivity))
                    }
                }
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
        let activity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep)
        ActivityDetailView(
            store: Store(
                initialState: ActivityDetail.State(activity: activity),
                reducer: ActivityDetail()))
    }
}
