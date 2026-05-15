//
//  CloudKitSyncService.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//
import Foundation
import CloudKit

/// Handles iCloud / CloudKit syncing for SecureScan Pro.
/// First version syncs OCR text metadata only, not scanned images/PDF files.
final class CloudKitSyncService {
    
    // MARK: - CloudKit Constants
    
    private let containerIdentifier = "iCloud.com.pratik.SecureScanPro"
    
    /// V2 avoids old CloudKit development schema conflicts from earlier tests.
    private let recordType = "ScannedDocument"
    
    /// Keeps CloudKit records lightweight.
    /// Later, long OCR text can be stored as CKAsset files.
    private let maxCloudTextCharacters = 20_000
    
    private enum FieldKey {
        static let documentID = "documentID"
        static let title = "title"
        static let recognizedText = "recognizedText"
        static let maskedText = "maskedText"
        static let isPrivacyMaskingEnabled = "isPrivacyMaskingEnabled"
        static let createdAt = "createdAt"
        static let note = "note"
    }
    
    private lazy var container = CKContainer(identifier: containerIdentifier)
    private lazy var database = container.privateCloudDatabase
    
    // MARK: - Account Status
    
    func checkAccountStatus() async -> CloudSyncStatus {
        do {
            let status = try await container.accountStatus()
            
            switch status {
            case .available:
                return .available
                
            case .noAccount:
                return .unavailable("No iCloud account is signed in on this device.")
                
            case .restricted:
                return .unavailable("iCloud is restricted on this device.")
                
            case .couldNotDetermine:
                return .unavailable("Could not determine iCloud account status.")
                
            case .temporarilyUnavailable:
                return .unavailable("iCloud is temporarily unavailable. Please try again later.")
                
            @unknown default:
                return .unavailable("Unknown iCloud account status.")
            }
        } catch {
            return .failed("Failed to check iCloud status: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Upload
    
    func uploadDocuments(_ documents: [ScannedDocument]) async throws {
        for document in documents {
            let record = makeRecord(from: document)
            _ = try await database.save(record)
        }
    }
    
    // MARK: - Fetch
    
    func fetchDocuments() async throws -> [ScannedDocument] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        // We intentionally do not use CloudKit sort descriptors here.
        // Sorting is done locally after fetch to avoid CloudKit index issues.
        let result = try await database.records(matching: query)
        var documents: [ScannedDocument] = []
        
        for (_, recordResult) in result.matchResults {
            switch recordResult {
            case .success(let record):
                if let document = makeDocument(from: record) {
                    documents.append(document)
                }
                
            case .failure(let error):
                print("Failed to fetch one CloudKit record: \(error.localizedDescription)")
            }
        }
        
        return documents.sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Delete
    
    func deleteDocument(_ document: ScannedDocument) async throws {
        let recordID = CKRecord.ID(recordName: document.id.uuidString)
        _ = try await database.deleteRecord(withID: recordID)
    }
    
    // MARK: - Record Conversion
    
    private func makeRecord(from document: ScannedDocument) -> CKRecord {
        let recordID = CKRecord.ID(recordName: document.id.uuidString)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        let safeRecognizedText = limitedText(document.recognizedText)
        let safeMaskedText = limitedText(document.maskedText)
        let safeNote = limitedText(document.note)
        
        record[FieldKey.documentID] = NSString(string: document.id.uuidString)
        record[FieldKey.title] = NSString(string: document.title)
        record[FieldKey.recognizedText] = NSString(string: safeRecognizedText)
        record[FieldKey.maskedText] = NSString(string: safeMaskedText)
        record[FieldKey.isPrivacyMaskingEnabled] = NSNumber(value: document.isPrivacyMaskingEnabled)
        record[FieldKey.createdAt] = document.createdAt as NSDate
        record[FieldKey.note] = NSString(string: safeNote)
        
        return record
    }
    
    private func makeDocument(from record: CKRecord) -> ScannedDocument? {
        guard
            let documentIDString = record[FieldKey.documentID] as? String,
            let id = UUID(uuidString: documentIDString),
            let title = record[FieldKey.title] as? String,
            let recognizedText = record[FieldKey.recognizedText] as? String,
            let maskedText = record[FieldKey.maskedText] as? String,
            let isPrivacyMaskingEnabledNumber = record[FieldKey.isPrivacyMaskingEnabled] as? NSNumber,
            let createdAt = record[FieldKey.createdAt] as? Date
        else {
            return nil
        }
        
        let note = record[FieldKey.note] as? String ?? ""
        
        return ScannedDocument(
            id: id,
            title: title,
            recognizedText: recognizedText,
            maskedText: maskedText,
            isPrivacyMaskingEnabled: isPrivacyMaskingEnabledNumber.boolValue,
            createdAt: createdAt,
            note: note,
            isSynced: true
        )
    }
    
    // MARK: - Safety Helpers
    
    private func limitedText(_ text: String) -> String {
        guard text.count > maxCloudTextCharacters else {
            return text
        }
        
        let limited = String(text.prefix(maxCloudTextCharacters))
        return limited + "\n\n[Text shortened for iCloud sync. Full text remains saved locally on this device.]"
    }
}
