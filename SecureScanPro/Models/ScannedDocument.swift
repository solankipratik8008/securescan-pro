//
//  ScannedDocument.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//
import Foundation

/// Represents one scanned document saved inside SecureScan Pro.
/// This model will be used first for local storage, and later for iCloud/CloudKit syncing.
struct ScannedDocument: Identifiable, Codable, Hashable {
    
    /// Unique ID for each scanned document.
    let id: UUID
    
    /// User-friendly title shown in scan history.
    var title: String
    
    /// Original OCR text extracted from the scanned document.
    var recognizedText: String
    
    /// Privacy-safe text after masking sensitive information.
    var maskedText: String
    
    /// Controls whether the app should show masked text or original text.
    var isPrivacyMaskingEnabled: Bool
    
    /// Date when the document was scanned.
    var createdAt: Date
    
    /// Optional user note for the document.
    var note: String
    
    /// Indicates whether this document is ready for future cloud syncing.
    var isSynced: Bool
    
    /// Text that should be displayed to the user based on the privacy toggle.
    var displayText: String {
        isPrivacyMaskingEnabled ? maskedText : recognizedText
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        recognizedText: String,
        maskedText: String,
        isPrivacyMaskingEnabled: Bool = true,
        createdAt: Date = Date(),
        note: String = "",
        isSynced: Bool = false
    ) {
        self.id = id
        self.title = title
        self.recognizedText = recognizedText
        self.maskedText = maskedText
        self.isPrivacyMaskingEnabled = isPrivacyMaskingEnabled
        self.createdAt = createdAt
        self.note = note
        self.isSynced = isSynced
    }
}
