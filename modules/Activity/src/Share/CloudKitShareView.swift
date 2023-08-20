//
//  CloudKitShareView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 16.3.2023.
//

import CloudKit
import SwiftUI
import NaptimeKit

struct CloudKitShareView: UIViewControllerRepresentable {
    let share: CKShare

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let sharingController = UICloudSharingController(
            share: share,
            container: CloudKitService.container
        )
        
        sharingController.availablePermissions = [.allowReadOnly, .allowPrivate]
        sharingController.modalPresentationStyle = .formSheet
        return sharingController
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) { }
}
