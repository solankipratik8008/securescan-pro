//
//  SavedScanDetailView.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//

internal import SwiftUI

struct SavedScanDetailView: View {
    
    @ObservedObject var viewModel: ScanViewModel
    @State private var document: ScannedDocument
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ScanViewModel, document: ScannedDocument) {
        self.viewModel = viewModel
        self._document = State(initialValue: document)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(document.title)
                        .font(.largeTitle.bold())
                    
                    Text(document.createdAt.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // MARK: - Status Card
                
                HStack(spacing: 12) {
                    Image(systemName: document.isSynced ? "icloud.fill" : "icloud.slash")
                        .font(.title2)
                        .foregroundStyle(document.isSynced ? .blue : .secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(document.isSynced ? "Synced with iCloud" : "Saved Locally")
                            .font(.headline)
                        
                        Text(document.isSynced ? "This scan is available through cloud sync." : "Cloud sync will be added in the next phase.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // MARK: - Privacy Toggle
                
                Toggle(isOn: $document.isPrivacyMaskingEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Privacy Masking")
                            .font(.headline)
                        
                        Text(document.isPrivacyMaskingEnabled ? "Sensitive information is hidden." : "Original OCR text is visible.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: document.isPrivacyMaskingEnabled) {
                    viewModel.updateDocument(document)
                }
                
                // MARK: - OCR Text
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(document.isPrivacyMaskingEnabled ? "Masked Text" : "Recognized Text")
                        .font(.title2.bold())
                    
                    Text(document.displayText.isEmpty ? "No text available." : document.displayText)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // MARK: - Actions
                
                Button(role: .destructive) {
                    viewModel.deleteDocument(document)
                    dismiss()
                } label: {
                    Label("Delete Scan", systemImage: "trash")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
        .navigationTitle("Scan Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
