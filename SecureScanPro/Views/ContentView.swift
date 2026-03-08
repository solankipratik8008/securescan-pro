//
//  ContentView.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-02-27.
//
import SwiftUI
import VisionKit

struct ContentView: View {
    
    // MARK: - ViewModel
    
    /// StateObject means this view OWNS the lifecycle of the ViewModel.
    /// SwiftUI keeps it alive as long as ContentView exists.
    @StateObject private var viewModel = ScanViewModel()
    
    
    // MARK: - Navigation State
    
    /// This variable controls navigation to the result screen.
    @State private var showResultScreen = false
    
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 24) {
                
                Spacer()
                
                // MARK: - App Icon
                
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                
                // MARK: - Title
                
                Text("SecureScan Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                
                // MARK: - Description
                
                Text("Scan sensitive documents securely with on-device OCR and real-time PII masking.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                
                Spacer()
                
                
                // MARK: - Scan Button
                
                Button {
                    
                    /// Ask ViewModel to start scanning
                    viewModel.startScanning()
                    
                } label: {
                    
                    Label("Start Secure Scan", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                
                
                Spacer()
            }
            .navigationTitle("Home")
            
            
            // MARK: - Scanner Sheet
            
            /// This sheet presents the document scanner.
            .sheet(isPresented: $viewModel.isScannerPresented) {
                
                ScannerView { scan in
                    
                    /// Process the scanned images
                    viewModel.processScan(scan)
                    
                    /// After processing, navigate to result screen
                    showResultScreen = true
                }
            }
            
            
            // MARK: - Navigation Destination
            
            /// When showResultScreen becomes true,
            /// SwiftUI pushes ScanResultView onto the navigation stack.
            .navigationDestination(isPresented: $showResultScreen) {
                
                ScanResultView(viewModel: viewModel)
            }
        }
    }
}
