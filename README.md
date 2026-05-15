# SecureScan Pro

SecureScan Pro is a privacy-first iOS document scanning app built with SwiftUI, VisionKit, Vision OCR, and CloudKit. The app allows users to scan physical documents, extract text using on-device OCR, optionally mask sensitive information, save scan history locally, search saved scans, and back up or restore saved scan data using iCloud.

This project was built as a portfolio-level iOS application to demonstrate practical SwiftUI development, Apple framework integration, MVVM architecture, local persistence, privacy-focused design, and CloudKit-based iCloud syncing.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [App Screens](#app-screens)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Privacy Approach](#privacy-approach)
- [CloudKit / iCloud Sync](#cloudkit--icloud-sync)
- [How to Run on Your Device](#how-to-run-on-your-device)
- [CloudKit Setup](#cloudkit-setup)
- [Required Capabilities](#required-capabilities)
- [Known Limitations](#known-limitations)
- [Future Improvements](#future-improvements)
- [Resume Highlight](#resume-highlight)
- [Author](#author)

---

## Overview

SecureScan Pro helps users scan documents and extract readable text directly on their iPhone. The app uses Apple’s VisionKit framework for document scanning and Vision framework for OCR text recognition.

The main goal of this app is to provide a simple but practical document scanning experience while keeping user privacy in mind. OCR processing happens on-device, and users can choose whether sensitive information should be hidden using the privacy masking toggle.

The app also includes local saved scan history and CloudKit-based iCloud backup/restore, making it more realistic than a basic scanner demo.

---

## Key Features

### Document Scanning

- Scan physical documents using the iPhone camera
- Uses Apple’s native VisionKit document scanner
- Supports multi-page document scanning through `VNDocumentCameraViewController`

### On-Device OCR

- Extracts text from scanned document images
- Uses Apple Vision framework
- OCR runs locally on the device
- No external OCR API is required

### Privacy Masking

- User-controlled privacy masking toggle
- Users can decide whether to show original OCR text or masked text
- Masks common sensitive information patterns such as:
  - Email addresses
  - Phone numbers
  - SIN-like numbers
  - Credit-card-like numbers

### Local Scan History

- Save scanned OCR results locally
- View saved scans on the home screen
- Open saved scan details
- Delete saved scans
- Search saved scans

### iCloud Backup and Restore

- Check iCloud account availability
- Upload saved scans to the user’s private CloudKit database
- Restore saved scans from iCloud
- Mark scans as synced after successful upload

### MVVM Architecture

- Clean separation between:
  - Views
  - ViewModels
  - Models
  - Services
- Easier to maintain and extend

---

## Demo Video

The project includes a screen recording that demonstrates the complete SecureScan Pro workflow, including document scanning, OCR extraction, privacy masking, local saved scan history, and CloudKit iCloud backup/restore.

[Watch Demo Video](Demo/securescan-pro-demo.mp4)

Demo flow:

1. Open SecureScan Pro
2. Check iCloud availability
3. Scan a document using VisionKit
4. Extract text using on-device Vision OCR
5. Toggle privacy masking ON/OFF
6. Save scan locally
7. Open saved scan detail
8. Sync saved scans to iCloud
9. Restore saved scans from iCloud








