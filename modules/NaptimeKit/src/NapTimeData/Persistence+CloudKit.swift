//
//  File.swift
//  
//
//  Created by Luca Kaufmann on 16.3.2023.
//
//  https://stackoverflow.com/questions/68021957/how-is-record-zone-sharing-done/68072464#68072464

import CloudKit
import UIKit
import CoreData
#if os(watchOS)
import DesignSystemWatchOS
#else
import DesignSystem
#endif

enum PersistenceError: Error {
    case noRecordsFound
}

extension PersistenceController {
    // For sharing see https://developer.apple.com/documentation/cloudkit/shared_records
    //
    private func share(completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        let recordZoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)
        let shareRecord = CKShare(recordZoneID: recordZoneID)

        var fullName = "Luca"
        shareRecord[CKShare.SystemFieldKey.title] = String(format: NSLocalizedString("SHARING_LIST_OF_USER", comment:" "), fullName)
//        let image = UIImage(named: kFileNameLogo)!.pngData()
//        shareRecord[CKShare.SystemFieldKey.thumbnailImageData] = image
//        // Include a custom UTI that describes the share's content.
//        shareRecord[CKShare.SystemFieldKey.shareType] = "com.zeh4soft.ShopEasy.shoppingList"

        let recordsToSave = [shareRecord]
        let container = CloudKitService.container
        let privateDatabase = container.privateCloudDatabase
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.perRecordProgressBlock = { (record, progress) in
            if progress < 1.0 {
                print("CloudKit error: Could not save record completely")
            }
        }

        operation.modifyRecordsResultBlock = { result in
            switch result {
                case .success:
                    completion(shareRecord, container, nil)
                case .failure(let error):
                    completion(nil, nil, error)
            }
        }

        privateDatabase.add(operation)
    }

    public func share() async -> CKShare {
        let recordZoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)
        let shareRecord = CKShare(recordZoneID: recordZoneID)

        shareRecord[CKShare.SystemFieldKey.title] = "Share naps"
//        let image = UIImage(named: "sleeping_teddy")!.pngData()
        let image = DesignSystemAsset.sleepingTeddy.image.pngData()
        shareRecord[CKShare.SystemFieldKey.thumbnailImageData] = image
        shareRecord.publicPermission = .readWrite
//        // Include a custom UTI that describes the share's content.
//        shareRecord[CKShare.SystemFieldKey.shareType] = "com.zeh4soft.ShopEasy.shoppingList"

        let recordsToSave = [shareRecord]
        let container = CloudKitService.container
        let privateDatabase = container.privateCloudDatabase
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.perRecordProgressBlock = { (record, progress) in
            if progress < 1.0 {
                print("CloudKit error: Could not save record completely")
            }
        }

        privateDatabase.add(operation)

        return shareRecord
    }
    
    public func getSharedShareRecord() -> [CKShare] {
        do {
            let shares = try container.fetchShares(in: sharedPersistentStore)
            return shares
        } catch {
            return []
        }
//        let query = CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true))
//        let container = CloudKitService.container
//
//
//
//        return try await withCheckedContinuation { continuation in
//            container.sharedCloudDatabase.fetch(withQuery: query) { result in
//                switch result {
//                    case .success(let returned):
//                        // .success((matchResults: [CKRecord.ID : Result<CKRecord, Error>], queryCursor: CKQueryOperation.Cursor?))
//                        let matchResults = returned.matchResults // [CKRecord.ID : Result<CKRecord, Error>]
//                        if let matchResult = matchResults.first {
//                            switch matchResult.1 {
//                                case .success(let ckRecord):
//                                    continuation.resume(returning: ckRecord as? CKShare)
//                                case .failure(let error):
//                                    continuation.resume(returning: nil)
////                                    continuation.resume(throwing: error)
//                            }
//                        } else {
//                            continuation.resume(returning: nil)
//
////                            continuation.resume(throwing: PersistenceError.noRecordsFound)
//                        }
//                    case .failure(let error):
////                        continuation.resume(throwing: error)
//                        continuation.resume(returning: nil)
//
//                }
//            }
//        }
    }

    public func getShareRecord() async -> CKShare? {
        let query = CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true))
        let container = CloudKitService.container
        return try await withCheckedContinuation { continuation in
            container.privateCloudDatabase.fetch(withQuery: query) { result in
                switch result {
                    case .success(let returned):
                        // .success((matchResults: [CKRecord.ID : Result<CKRecord, Error>], queryCursor: CKQueryOperation.Cursor?))
                        let matchResults = returned.matchResults // [CKRecord.ID : Result<CKRecord, Error>]
                        if let matchResult = matchResults.first {
                            switch matchResult.1 {
                                case .success(let ckRecord):
                                    continuation.resume(returning: ckRecord as? CKShare)
                                case .failure(let error):
                                    continuation.resume(returning: nil)
//                                    continuation.resume(throwing: error)
                            }
                        } else {
                            continuation.resume(returning: nil)

//                            continuation.resume(throwing: PersistenceError.noRecordsFound)
                        }
                    case .failure(let error):
//                        continuation.resume(throwing: error)
                        continuation.resume(returning: nil)

                }
            }
        }
        
    }
    
    func shareObject(_ unsharedObject: NSManagedObject, to existingShare: CKShare?) async throws -> CKShare?
    {
        return try await withCheckedThrowingContinuation { continuation in
            container.share([unsharedObject], to: existingShare) { (objectIDs, share, container, error) in
                guard error == nil, let share = share else {
                    print("\(#function): Failed to share an object: \(error!))")
                    continuation.resume(throwing: error!)
                    return
                }
                /**
                 Synchronize the changes on the share to the private persistent store.
                 */
                self.container.persistUpdatedShare(share, in: self.privatePersistentStore) { (share, error) in
                    if let error = error {
                        print("\(#function): Failed to persist updated share: \(error)")
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: share)
                }
            }
        }
    }

}
