//
//  DocumentStorageService.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//

import Foundation
internal import SwiftUI

/// Handles local saving and loading of scanned documents.
/// For now, this uses JSON file storage inside the app's Documents directory.
/// Later, we can connect this saved data to CloudKit/iCloud sync.
final class DocumentStorageService {
    
    private let fileName = "saved_scanned_documents.json"
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    /// Loads all saved scanned documents from local storage.
    func loadDocuments() -> [ScannedDocument] {
        do {
            let data = try Data(contentsOf: fileURL)
            let documents = try JSONDecoder().decode([ScannedDocument].self, from: data)
            return documents.sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }
    
    /// Saves the full scanned document list to local storage.
    func saveDocuments(_ documents: [ScannedDocument]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(documents)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save scanned documents: \(error.localizedDescription)")
        }
    }
    
    /// Adds a new scanned document and saves the updated list.
    func addDocument(_ document: ScannedDocument) {
        var documents = loadDocuments()
        documents.insert(document, at: 0)
        saveDocuments(documents)
    }
    
    /// Updates an existing scanned document.
    func updateDocument(_ updatedDocument: ScannedDocument) {
        var documents = loadDocuments()
        
        guard let index = documents.firstIndex(where: { $0.id == updatedDocument.id }) else {
            return
        }
        
        documents[index] = updatedDocument
        saveDocuments(documents)
    }
    
    /// Deletes a saved scanned document.
    func deleteDocument(_ document: ScannedDocument) {
        var documents = loadDocuments()
        documents.removeAll { $0.id == document.id }
        saveDocuments(documents)
    }
    
    /// Deletes multiple saved scanned documents.
    func deleteDocuments(at offsets: IndexSet, from documents: [ScannedDocument]) {
        var updatedDocuments = documents
        updatedDocuments.remove(atOffsets: offsets)
        saveDocuments(updatedDocuments)
    }
}
