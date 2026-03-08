//
//  ScannerView.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-03-03.
//

import SwiftUI          // Needed for SwiftUI views and UIViewControllerRepresentable
import VisionKit        // Provides VNDocumentCameraViewController (Apple's document scanner)

/// ScannerView wraps a UIKit controller (VNDocumentCameraViewController)
/// so it can be used inside SwiftUI.
/// This is called a "UIKit bridge".
struct ScannerView: UIViewControllerRepresentable {
    
    // MARK: - Environment
    
    /// Injected from SwiftUI's environment.
    /// Provides a dismiss action when this view is presented modally (e.g., via .sheet).
    /// This is dependency injection via Environment.
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Callback
    
    /// Closure that passes the completed scan back to the parent SwiftUI view.
    /// This is how we communicate results upward in SwiftUI.
    var onScanCompleted: (VNDocumentCameraScan) -> Void
    
    // MARK: - Create UIKit Controller
    
    /// Called once when SwiftUI creates the UIKit controller.
    /// This is where we instantiate and configure VNDocumentCameraViewController.
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        
        // Create Apple's built-in document scanner
        let scanner = VNDocumentCameraViewController()
        
        // Assign the delegate to the Coordinator
        // UIKit uses delegate pattern, so we must assign it here.
        scanner.delegate = context.coordinator
        
        return scanner
    }
    
    // MARK: - Update UIKit Controller
    
    /// Called whenever SwiftUI state changes and the UIKit controller
    /// needs to be updated to reflect new state.
    ///
    /// In our case, we don't need dynamic updates while the scanner is active,
    /// so this remains empty.
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController,
                                context: Context) {
        // No dynamic updates needed
    }
    
    // MARK: - Coordinator
    
    /// Creates a Coordinator instance.
    /// The Coordinator acts as a bridge between UIKit delegate callbacks
    /// and SwiftUI.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator Class
    
    /// Coordinator is required because UIKit uses delegate pattern,
    /// and SwiftUI needs a reference-type object to handle delegate callbacks.
    ///
    /// Must inherit from NSObject because UIKit delegates require it.
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        /// Reference to the parent ScannerView.
        /// This allows delegate methods to communicate back to SwiftUI.
        let parent: ScannerView
        
        /// Initialize with parent reference.
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        // MARK: - Delegate Methods
        
        /// Called when user successfully finishes scanning documents.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            
            // Pass scanned result back to SwiftUI via closure
            parent.onScanCompleted(scan)
            
            // Dismiss the scanner sheet using Environment dismiss action
            parent.dismiss()
        }
        
        /// Called when user taps Cancel.
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            
            // Simply dismiss the scanner
            parent.dismiss()
        }
        
        /// Called when scanner encounters an error.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            
            // Log error (for debugging purposes)
            print("Scanner error: \(error.localizedDescription)")
            
            // Dismiss scanner even if error occurs
            parent.dismiss()
        }
    }
}
