# SecureScan Pro

SecureScan Pro is a privacy-first iOS document scanning app built with SwiftUI, VisionKit, Vision OCR, and CloudKit. The app lets users scan documents, extract text using on-device OCR, mask sensitive information, save scan history locally, search saved scans, and back up/restore scan data using iCloud.

▶️ Demo Video: https://youtube.com/shorts/Ud0FcUpXZe0

[![Watch the SecureScan Pro demo](https://img.youtube.com/vi/Ud0FcUpXZe0/hqdefault.jpg)](https://youtube.com/shorts/Ud0FcUpXZe0)

---

## Features

- Scan physical documents using VisionKit
- Extract text using Apple Vision OCR
- On-device OCR processing with no external OCR API
- Privacy masking for emails, phone numbers, SIN-like numbers, and credit-card-like numbers
- Save scanned text locally
- Search saved scans
- Open scan detail view
- Delete saved scans
- Check iCloud availability
- Back up saved scans to CloudKit
- Restore saved scans from iCloud
- MVVM-based project structure

---

## Tech Stack

- Swift
- SwiftUI
- VisionKit
- Vision OCR
- CloudKit
- iCloud
- MVVM
- Local persistence
- Xcode

---

## Demo Flow

1. Open SecureScan Pro
2. Check iCloud availability
3. Scan a document using VisionKit
4. Extract text using on-device OCR
5. Toggle privacy masking ON/OFF
6. Save scan locally
7. View saved scan detail
8. Search saved scans
9. Sync scans to iCloud
10. Restore scans from iCloud

---

## Project Structure

```text
SecureScanPro
├── Models
├── Views
├── ViewModels
├── Services
├── Assets.xcassets
└── README.md


How to Run on Your Device
Requirements
macOS
Xcode
iPhone with camera
Apple Developer account
iCloud account signed in on the device
Steps
git clone https://github.com/solankipratik8008/securescan-pro.git
cd securescan-pro
open SecureScanPro.xcodeproj

Then in Xcode:

Select the project target.
Go to Signing & Capabilities.
Select your Apple Developer Team.
Add iCloud capability.
Enable CloudKit.
Select or create a CloudKit container.
Add Camera Usage Description in Info.plist.
Build with Command + B.
Run on a real iPhone with Command + R.
Required Permissions and Capabilities
Camera permission for document scanning
iCloud capability
CloudKit capability

Recommended Info.plist camera message:

SecureScan Pro uses the camera to scan documents.
CloudKit Setup

To use iCloud backup and restore:

Enable iCloud in Signing & Capabilities.
Check CloudKit.
Select a CloudKit container.
Make sure the device is signed into iCloud.
Make sure iCloud Drive is enabled.
Run the app on a physical iPhone.
Privacy Note

SecureScan Pro performs OCR on-device using Apple Vision. It does not use a third-party OCR API. The privacy masking feature helps hide common sensitive data patterns, but users should still review extracted text before sharing or storing important documents.

Known Limitations
OCR accuracy depends on document quality and lighting.
Privacy masking may not detect every sensitive format.
CloudKit setup requires correct Apple Developer signing and iCloud configuration.
Sync is implemented as a backup/restore workflow.
PDF export is not included yet.
Future Improvements
PDF export
Share sheet support
Face ID / Touch ID lock
Folder and tag organization
Better sensitive data detection
Improved CloudKit sync status UI
Batch scan export
Unit tests for privacy masking and storage logic
Resume Highlight

SecureScan Pro - SwiftUI, VisionKit, Vision OCR, CloudKit, MVVM
Built a privacy-first iOS document scanner using VisionKit and on-device Vision OCR, featuring user-controlled privacy masking, searchable saved scan history, and CloudKit-based iCloud backup/restore.

Author

Pratikkumar Solanki

GitHub: https://github.com/solankipratik8008
LinkedIn: https://www.linkedin.com/in/pratikkumar-solanki-045b62365
Portfolio: https://solankipratik8008.github.io/Portfolio/
Disclaimer

SecureScan Pro is a portfolio/demo app created for learning and showcasing iOS development skills. The privacy masking feature is rule-based and may not detect every possible sensitive data pattern.
