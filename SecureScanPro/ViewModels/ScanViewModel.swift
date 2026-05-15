//
//  ScanViewModel.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-03-03.
//


import CloudKit
import Foundation
internal import SwiftUI
import VisionKit
import Vision
import UIKit
internal import Combine

@MainActor
final class ScanViewModel: ObservableObject {
    
    // MARK: - Scanner State
    
    @Published var isScannerPresented: Bool = false
    @Published var recognizedText: String = ""
    @Published var maskedText: String = ""
    @Published var isPrivacyMaskingEnabled: Bool = true
    
    // MARK: - Saved Documents State
    
    @Published var savedDocuments: [ScannedDocument] = []
    @Published var searchText: String = ""
    @Published var showSaveSuccessMessage: Bool = false
    
    // MARK: - Cloud Sync State
    
    @Published var cloudSyncStatus: CloudSyncStatus = .notStarted
    
    // MARK: - Services
    
    private let piiMaskingService = PIIMaskingService()
    private let storageService = DocumentStorageService()
    private let cloudKitSyncService = CloudKitSyncService()
    
    // MARK: - Computed Properties
    
    var displayText: String {
        isPrivacyMaskingEnabled ? maskedText : recognizedText
    }
    
    var hasRecognizedText: Bool {
        !recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var filteredDocuments: [ScannedDocument] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedSearch.isEmpty else {
            return savedDocuments
        }
        
        return savedDocuments.filter { document in
            document.title.localizedCaseInsensitiveContains(trimmedSearch) ||
            document.recognizedText.localizedCaseInsensitiveContains(trimmedSearch) ||
            document.maskedText.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }
    
    // MARK: - Init
    
    init() {
        loadSavedDocuments()
    }
    
    // MARK: - Scanner Actions
    
    func startScanning() {
        isScannerPresented = true
    }
    
    func dismissScanner() {
        isScannerPresented = false
    }
    
    func processScan(_ scan: VNDocumentCameraScan) {
        isScannerPresented = false
        
        var fullRecognizedText = ""
        
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            let pageText = recognizeText(from: image)
            
            if !pageText.isEmpty {
                fullRecognizedText += pageText
                
                if pageIndex < scan.pageCount - 1 {
                    fullRecognizedText += "\n\n"
                }
            }
        }
        
        updateRecognizedText(fullRecognizedText)
    }
    
    // MARK: - OCR Result Handling
    
    func updateRecognizedText(_ text: String) {
        recognizedText = text
        maskedText = piiMaskingService.maskSensitiveInformation(in: text)
    }
    
    func clearCurrentScan() {
        recognizedText = ""
        maskedText = ""
        isPrivacyMaskingEnabled = true
    }
    
    // MARK: - Local Storage
    
    func loadSavedDocuments() {
        savedDocuments = storageService.loadDocuments()
    }
    
    func saveCurrentScan() {
        guard hasRecognizedText else {
            return
        }
        
        let title = generateDocumentTitle()
        
        let document = ScannedDocument(
            title: title,
            recognizedText: recognizedText,
            maskedText: maskedText,
            isPrivacyMaskingEnabled: isPrivacyMaskingEnabled,
            createdAt: Date(),
            note: "",
            isSynced: false
        )
        
        storageService.addDocument(document)
        loadSavedDocuments()
        showSaveSuccessMessage = true
    }
    
    func updateDocument(_ document: ScannedDocument) {
        storageService.updateDocument(document)
        loadSavedDocuments()
    }
    
    func deleteDocument(_ document: ScannedDocument) {
        storageService.deleteDocument(document)
        loadSavedDocuments()
        
        Task {
            do {
                try await cloudKitSyncService.deleteDocument(document)
            } catch {
                cloudSyncStatus = .failed("Deleted locally, but failed to delete from iCloud: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteDocuments(at offsets: IndexSet) {
        let documentsToDeleteFrom = filteredDocuments
        
        for index in offsets {
            guard documentsToDeleteFrom.indices.contains(index) else {
                continue
            }
            
            deleteDocument(documentsToDeleteFrom[index])
        }
        
        loadSavedDocuments()
    }
    
    // MARK: - CloudKit Sync
    
    func checkCloudStatus() {
        cloudSyncStatus = .checkingAccount
        
        Task {
            let status = await cloudKitSyncService.checkAccountStatus()
            cloudSyncStatus = status
        }
    }
    
    func syncWithICloud() {
        cloudSyncStatus = .syncing
        
        Task {
            do {
                let localDocuments = storageService.loadDocuments()
                
                // Upload saved local scans to the user's private iCloud database.
                try await cloudKitSyncService.uploadDocuments(localDocuments)
                
                // After upload succeeds, mark local scans as synced.
                let syncedDocuments = localDocuments.map { document in
                    var updatedDocument = document
                    updatedDocument.isSynced = true
                    return updatedDocument
                }
                
                storageService.saveDocuments(syncedDocuments)
                savedDocuments = syncedDocuments.sorted { $0.createdAt > $1.createdAt }
                
                cloudSyncStatus = .synced(Date())
            } catch {
                cloudSyncStatus = .failed(makeUserFriendlyCloudErrorMessage(from: error))
            }
        }
    }
    
    private func mergeDocuments(
        localDocuments: [ScannedDocument],
        cloudDocuments: [ScannedDocument]
    ) -> [ScannedDocument] {
        var documentMap: [UUID: ScannedDocument] = [:]
        
        // Add cloud documents first.
        for cloudDocument in cloudDocuments {
            documentMap[cloudDocument.id] = cloudDocument
        }
        
        // Prefer local documents when the same scan exists locally,
        // because local text may contain the full OCR result.
        for localDocument in localDocuments {
            var updatedLocalDocument = localDocument
            updatedLocalDocument.isSynced = true
            documentMap[localDocument.id] = updatedLocalDocument
        }
        
        return Array(documentMap.values)
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - OCR Helper
    
    private func recognizeText(from image: UIImage) -> String {
        guard let cgImage = image.cgImage else {
            return ""
        }
        
        var recognizedStrings: [String] = []
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR error: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            let pageText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            recognizedStrings.append(contentsOf: pageText)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform OCR request: \(error.localizedDescription)")
        }
        
        return recognizedStrings.joined(separator: "\n")
    }
    
    // MARK: - Private Helpers
    
    private func generateDocumentTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy - h:mm a"
        return "Scan \(formatter.string(from: Date()))"
    }
    
    
    private func makeUserFriendlyCloudErrorMessage(from error: Error) -> String {
        if let ckError = error as? CKError {
            print("CloudKit CKError code: \(ckError.code)")
            print("CloudKit CKError description: \(ckError.localizedDescription)")
            print("CloudKit CKError userInfo: \(ckError.userInfo)")
            
            switch ckError.code {
            case .quotaExceeded:
                return "CloudKit quota was exceeded. Try deleting old development records in CloudKit Console, then sync again."
                
            case .notAuthenticated:
                return "iCloud is not authenticated. Please sign in to iCloud on this iPhone."
                
            case .networkFailure, .networkUnavailable:
                return "Network issue. Please check Wi-Fi/mobile data and try again."
                
            case .serverRecordChanged:
                return "This scan was changed in iCloud. Please try syncing again."
                
            case .unknownItem:
                return "CloudKit could not find the required record or zone. Check the CloudKit container."
                
            case .partialFailure:
                return "CloudKit partially failed while syncing. Check Xcode console for failed record details."
                
            case .invalidArguments:
                if ckError.localizedDescription.contains("recordName") {
                    return "CloudKit schema needs an index update. In CloudKit Console, mark recordName as Queryable for SecureScannedDocumentV2."
                }
                
                if ckError.localizedDescription.contains("createdAt") {
                    return "CloudKit schema needs an index update. In CloudKit Console, mark createdAt as Sortable for SecureScannedDocumentV2."
                }
                
                return "CloudKit rejected one of the saved fields. Check the CloudKit schema."
                
            default:
                return "CloudKit error: \(ckError.code.rawValue) - \(ckError.localizedDescription)"
            }
        }
        
        print("Non-CloudKit sync error: \(error.localizedDescription)")
        return "iCloud sync failed: \(error.localizedDescription)"
    }
}
