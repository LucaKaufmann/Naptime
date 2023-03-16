//
//  File.swift
//  
//
//  Created by Luca Kaufmann on 16.3.2023.
//
//  https://stackoverflow.com/questions/68021957/how-is-record-zone-sharing-done/68072464#68072464

import CloudKit

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
        let container = CKContainer.default()
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

    public func share() async throws -> CKShare {
        let recordZoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)
        let shareRecord = CKShare(recordZoneID: recordZoneID)

        var fullName = "Luca"
        shareRecord[CKShare.SystemFieldKey.title] = String(format: NSLocalizedString("SHARING_LIST_OF_USER", comment:" "), fullName)
//        let image = UIImage(named: kFileNameLogo)!.pngData()
//        shareRecord[CKShare.SystemFieldKey.thumbnailImageData] = image
//        // Include a custom UTI that describes the share's content.
//        shareRecord[CKShare.SystemFieldKey.shareType] = "com.zeh4soft.ShopEasy.shoppingList"

        let recordsToSave = [shareRecord]
        let container = CKContainer.default()
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

    public func getShareRecord() async throws -> CKShare? {
        let query = CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true))
        let container = CKContainer.default()
        return try await withCheckedThrowingContinuation { continuation in
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
                                    continuation.resume(throwing: error)
                            }
                        } else {
                            continuation.resume(throwing: PersistenceError.noRecordsFound)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        }
        
    }

}
