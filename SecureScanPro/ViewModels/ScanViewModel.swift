//
//  ScanViewModel.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-03-03.
//
import SwiftUI
import VisionKit
import Vision
import Combine
/// ViewModel responsible for scanning logic and OCR processing
@MainActor
final class ScanViewModel: ObservableObject {
    
    
    // MARK: - Published Properties
    
    /// Holds OCR result text after processing
    /// SwiftUI updates UI automatically when this changes
    @Published var scannedText: String = ""
    
    /// Controls presentation of the scanner sheet
    @Published var isScannerPresented: Bool = false
    
    
    // MARK: - Start Scanning
    
    /// Called when user taps the "Start Secure Scan" button
    /// It simply changes state which triggers the sheet presentation
    func startScanning() {
        isScannerPresented = true
    }
    
    
    // MARK: - Process Scan Result
    
    /// Called after VisionKit finishes scanning documents
    /// Receives all scanned pages
    func processScan(_ scan: VNDocumentCameraScan) {
        
        // Reset previous text
        scannedText = ""
        
        // Loop through all scanned pages
        for pageIndex in 0..<scan.pageCount {
            
            // Extract image of the page
            let image = scan.imageOfPage(at: pageIndex)
            
            // Run OCR on the image
            recognizeText(from: image)
        }
    }
    
    
    // MARK: - OCR Processing
    
    /// Performs OCR using Apple Vision Framework
    private func recognizeText(from image: UIImage) {
        
        // Convert UIImage to CGImage
        guard let cgImage = image.cgImage else { return }
        
        // Create a text recognition request
        let request = VNRecognizeTextRequest { request, error in
            
            if let error = error {
                print("OCR Error:", error.localizedDescription)
                return
            }
            
            // Extract recognized text
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            // Append recognized text to our state variable
            DispatchQueue.main.async {
                self.scannedText += recognizedStrings.joined(separator: "\n")
            }
        }
        
        // Set recognition accuracy level
        request.recognitionLevel = .accurate
        
        // Create image request handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            // Run OCR
            try handler.perform([request])
        } catch {
            print("Failed to perform OCR:", error.localizedDescription)
        }
    }
}
