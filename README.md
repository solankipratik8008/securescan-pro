# SecureScan Pro

SecureScan Pro is an iOS document scanning application built with Swift and Apple’s on-device AI frameworks. The app allows users to scan documents, extract text using OCR, and detect sensitive information such as personal identification numbers, card numbers, and private document details while keeping processing local on the device.

This project is designed as a privacy-focused iOS portfolio application demonstrating real-world skills in Swift, Vision, AVFoundation, CoreML, MVVM architecture, and performance-conscious mobile development.

---

## Overview

SecureScan Pro focuses on secure document capture and intelligent text recognition. Instead of sending scanned data to external servers, the app uses Apple’s on-device frameworks to process documents locally, making it suitable for privacy-sensitive use cases such as banking, legal, healthcare, education, and personal document management.

---

## Key Features

- Scan documents using the iPhone camera
- Extract text from scanned documents using Apple Vision OCR
- Detect sensitive information from extracted text
- Highlight or mask private information for safer sharing
- Process images asynchronously to keep the UI responsive
- Use on-device processing to protect user privacy
- Clean SwiftUI interface with a simple scanning workflow
- MVVM architecture for maintainable and testable code
- Performance-focused camera and OCR processing

---

## Tech Stack

### iOS Development
- Swift
- SwiftUI
- UIKit integration where needed
- MVVM architecture
- Swift Concurrency / async-await

### Apple Frameworks
- Vision
- AVFoundation
- CoreML
- VisionKit
- Foundation

### Tools
- Xcode
- Git
- GitHub
- Instruments

---

## Main Modules

```text
SecureScanPro/
│
├── Models/
│   ├── ScannedDocument.swift
│   ├── OCRResult.swift
│   └── SensitiveDataType.swift
│
├── ViewModels/
│   ├── ScannerViewModel.swift
│   ├── OCRViewModel.swift
│   └── DocumentResultViewModel.swift
│
├── Views/
│   ├── HomeView.swift
│   ├── ScannerView.swift
│   ├── OCRResultView.swift
│   └── SettingsView.swift
│
├── Services/
│   ├── OCRService.swift
│   ├── SensitiveDataDetector.swift
│   └── ImageProcessingService.swift
│
├── Utilities/
│   ├── RegexPatterns.swift
│   ├── ImagePreprocessor.swift
│   └── AppConstants.swift
│
└── Resources/
    └── Assets.xcassets
