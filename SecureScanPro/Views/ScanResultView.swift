//
//  ScanResultView.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-03-08.
//

internal import SwiftUI

struct ScanResultView: View {
    
    @ObservedObject var viewModel: ScanViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)
                            .frame(width: 52, height: 52)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scan Result")
                        .font(.largeTitle.bold())
                    
                    Text("Review the recognized text, turn privacy masking on or off, and save the scan.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // MARK: - Privacy Toggle
                
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $viewModel.isPrivacyMaskingEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Privacy Masking")
                                .font(.headline)
                            
                            Text(viewModel.isPrivacyMaskingEnabled ? "Sensitive information is hidden." : "Original OCR text is visible.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // MARK: - Recognized Text
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.isPrivacyMaskingEnabled ? "Masked Text" : "Recognized Text")
                        .font(.title2.bold())
                    
                    Text(viewModel.displayText.isEmpty ? "No text recognized." : viewModel.displayText)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // MARK: - Actions
                
                VStack(spacing: 12) {
                    Button {
                        viewModel.saveCurrentScan()
                    } label: {
                        Label("Save Scan", systemImage: "tray.and.arrow.down.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.hasRecognizedText ? Color.blue : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!viewModel.hasRecognizedText)
                    
                    Button {
                        viewModel.clearCurrentScan()
                        dismiss()
                    } label: {
                        Label("Discard Scan", systemImage: "trash")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert("Scan Saved", isPresented: $viewModel.showSaveSuccessMessage) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your scan has been saved locally.")
        }
    }
}
