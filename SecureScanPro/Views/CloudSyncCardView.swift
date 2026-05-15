//
//  CloudSyncCardView.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//
internal import SwiftUI

struct CloudSyncCardView: View {
    
    let status: CloudSyncStatus
    let onCheckStatus: () -> Void
    let onSync: () -> Void
    let onRestore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: 42, height: 42)
                    .background(iconColor.opacity(0.12))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(status.title)
                        .font(.headline)
                    
                    Text(status.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if status.isSyncing {
                    ProgressView()
                }
            }
            
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Button {
                        onCheckStatus()
                    } label: {
                        Label("Check", systemImage: "checkmark.icloud")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(status.isSyncing)
                    
                    Button {
                        onSync()
                    } label: {
                        Label("Sync", systemImage: "arrow.triangle.2.circlepath.icloud.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(status.isSyncing ? Color.gray : Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(status.isSyncing)
                }
                
                Button {
                    onRestore()
                } label: {
                    Label("Restore from iCloud", systemImage: "icloud.and.arrow.down.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(status.isSyncing)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var iconName: String {
        switch status {
        case .notStarted:
            return "icloud"
        case .checkingAccount:
            return "icloud.and.arrow.up"
        case .available:
            return "checkmark.icloud.fill"
        case .unavailable:
            return "exclamationmark.icloud"
        case .syncing:
            return "arrow.triangle.2.circlepath.icloud"
        case .synced:
            return "checkmark.icloud.fill"
        case .failed:
            return "xmark.icloud"
        }
    }
    
    private var iconColor: Color {
        switch status {
        case .available, .synced:
            return .green
        case .failed, .unavailable:
            return .red
        case .syncing, .checkingAccount:
            return .blue
        case .notStarted:
            return .secondary
        }
    }
}
