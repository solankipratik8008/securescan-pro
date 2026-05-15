//
//  SavedScanRow.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//

internal import SwiftUI

struct SavedScanRow: View {
    
    let document: ScannedDocument
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top) {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(document.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: document.isPrivacyMaskingEnabled ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(document.isPrivacyMaskingEnabled ? .orange : .green)
                    
                    Image(systemName: document.isSynced ? "icloud.fill" : "icloud.slash")
                        .foregroundStyle(document.isSynced ? .blue : .secondary)
                }
            }
            
            Text(document.displayText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            HStack(spacing: 8) {
                Label(
                    document.isPrivacyMaskingEnabled ? "Masked" : "Original",
                    systemImage: document.isPrivacyMaskingEnabled ? "eye.slash" : "eye"
                )
                
                Label(
                    document.isSynced ? "Synced" : "Local only",
                    systemImage: document.isSynced ? "icloud.fill" : "iphone"
                )
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .contentShape(Rectangle())
    }
}
