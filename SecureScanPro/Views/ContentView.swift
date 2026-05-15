//
//  ContentView.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-02-27.
//
internal import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ScanViewModel()
    @State private var selectedDocument: ScannedDocument?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        // MARK: - Header
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Home")
                                .font(.largeTitle.bold())
                            
                            HStack(spacing: 14) {
                                Image(systemName: "doc.viewfinder")
                                    .font(.system(size: 38, weight: .semibold))
                                    .foregroundStyle(.blue)
                                    .frame(width: 64, height: 64)
                                    .background(Color.blue.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SecureScan Pro")
                                        .font(.title2.bold())
                                    
                                    Text("On-device OCR with optional privacy masking.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // MARK: - Scan Button
                        
                        Button {
                            viewModel.startScanning()
                        } label: {
                            Label("Start Secure Scan", systemImage: "camera.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        
                        // MARK: - iCloud Sync Card

                        CloudSyncCardView(
                            status: viewModel.cloudSyncStatus,
                            onCheckStatus: {
                                viewModel.checkCloudStatus()
                            },
                            onSync: {
                                viewModel.syncWithICloud()
                            },
                            onRestore: {
                                viewModel.restoreFromICloud()
                            }
                        )
                        
                        // MARK: - Saved Scans
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Saved Scans")
                                    .font(.title2.bold())
                                
                                Spacer()
                                
                                Text("\(viewModel.savedDocuments.count)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                            
                            if viewModel.savedDocuments.isEmpty {
                                emptyStateView
                            } else {
                                searchField
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredDocuments) { document in
                                        Button {
                                            selectedDocument = document
                                        } label: {
                                            SavedScanRow(document: document)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isScannerPresented) {
                ScannerView(onScanCompleted: { scan in
                    viewModel.processScan(scan)
                })
            }
            .navigationDestination(isPresented: Binding(
                get: { viewModel.hasRecognizedText },
                set: { isPresented in
                    if !isPresented {
                        viewModel.clearCurrentScan()
                    }
                }
            )) {
                ScanResultView(viewModel: viewModel)
            }
            .sheet(item: $selectedDocument) { document in
                NavigationStack {
                    SavedScanDetailView(viewModel: viewModel, document: document)
                }
            }
            .onAppear {
                viewModel.loadSavedDocuments()
                viewModel.checkCloudStatus()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            
            Text("No saved scans yet")
                .font(.headline)
            
            Text("Start a secure scan and save the OCR result to build your scan history.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Search Field
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search saved scans", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
