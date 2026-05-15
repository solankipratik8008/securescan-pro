//
//  CloudSyncStatus.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//

import Foundation

/// Represents the current iCloud sync state for SecureScan Pro.
enum CloudSyncStatus: Equatable {
    case notStarted
    case checkingAccount
    case available
    case unavailable(String)
    case syncing
    case synced(Date)
    case failed(String)
    
    var title: String {
        switch self {
        case .notStarted:
            return "iCloud Sync Not Started"
        case .checkingAccount:
            return "Checking iCloud Status"
        case .available:
            return "iCloud Available"
        case .unavailable:
            return "iCloud Unavailable"
        case .syncing:
            return "Syncing with iCloud"
        case .synced:
            return "Synced with iCloud"
        case .failed:
            return "iCloud Sync Failed"
        }
    }
    
    var message: String {
        switch self {
        case .notStarted:
            return "Your scans are currently saved locally."
        case .checkingAccount:
            return "Checking whether iCloud is available on this device."
        case .available:
            return "iCloud is available. You can sync saved scans."
        case .unavailable(let reason):
            return reason
        case .syncing:
            return "Uploading and downloading saved scans."
        case .synced(let date):
            return "Last synced \(date.formatted(date: .abbreviated, time: .shortened))."
        case .failed(let error):
            return error
        }
    }
    
    var isSyncing: Bool {
        if case .syncing = self {
            return true
        }
        return false
    }
}
