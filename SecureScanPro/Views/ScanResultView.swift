//
//  ScanResultView.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-03-08.
//

import SwiftUI

/// This view displays the OCR results after scanning.
/// It reads the recognized text from the ViewModel.
struct ScanResultView: View {
    
    // MARK: - ViewModel
    
    /// ObservedObject means this view observes changes
    /// from the ScanViewModel but does not own it.
    @ObservedObject var viewModel: ScanViewModel
    
    
    // MARK: - UI
    
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                // Title
                Text("Recognized Text")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                
                // Scrollable OCR text
                ScrollView {
                    
                    Text(viewModel.scannedText)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                
                Spacer()
            }
            .padding()
            .navigationTitle("Scan Result")
        }
    }
}
