//
//  CloudKitShareView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 16.3.2023.
//

import CloudKit
import SwiftUI

#if os(iOS)
public struct CloudKitShareView: UIViewControllerRepresentable {
    
    public init(share: CKShare) {
        self.share = share
    }
    
    let share: CKShare

    public func makeUIViewController(context: Context) -> UICloudSharingController {
        let sharingController = UICloudSharingController(
            share: share,
            container: CloudKitService.container
        )
        
        sharingController.availablePermissions = [.allowReadOnly, .allowPrivate]
        sharingController.modalPresentationStyle = .formSheet
        return sharingController
    }

    public func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) { }
}
#endif
