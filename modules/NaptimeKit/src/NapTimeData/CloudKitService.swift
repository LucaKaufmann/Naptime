//
//  File.swift
//  
//
//  Created by Luca Kaufmann on 16.3.2023.
//

import CloudKit

private enum SharedZone {
    static let name = "SharedZone"
    static let ID = CKRecordZone.ID(
        zoneName: name,
        ownerName: CKCurrentUserDefaultName
    )
}

public final class CloudKitService {
    public static let container = CKContainer(
        identifier: "iCloud.com.hotky.naptime"
    )
    
    public func save() async throws {
        _ = try await Self.container.privateCloudDatabase.modifyRecordZones(
            saving: [CKRecordZone(zoneName: SharedZone.name)],
            deleting: []
        )
//        _ = try await Self.container.privateCloudDatabase.modifyRecords(
//            saving: [fasting.asRecord],
//            deleting: []
//        )
    }
}
