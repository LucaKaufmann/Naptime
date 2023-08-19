//
//  SceneDelegate.swift
//  Naptime
//
//  Created by Luca Kaufmann on 26.3.2023.
//

import UIKit
import CloudKit
import NaptimeKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        let persistence = PersistenceController.shared

        // Get references to the app's persistent container
        // and shared persistent store.
        let container = persistence.container
        let store = persistence.sharedPersistentStore

        // Tell the container to accept the specified share, adding
        // the shared objects to the shared persistent store.
       container.acceptShareInvitations(from: [cloudKitShareMetadata],
                                        into: store,
                                        completion: nil)
    }
}
