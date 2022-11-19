//
//  NaptimeApp.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.11.2022.
//

import SwiftUI

@main
struct NaptimeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
