# <img width="64" height="64" alt="iTunesArtwork-1024" src="https://github.com/user-attachments/assets/738a7894-b9b1-49f9-8853-52111e2236c8" /> Leevda - Vocabulary Learning App 


<div align="center">

  ![Platform](https://img.shields.io/badge/Platform-iOS%2016.0+-blue.svg)
  ![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-green.svg)
  ![License](https://img.shields.io/badge/License-MIT-purple.svg)

  **A beautiful, dark-themed iOS app for learning vocabulary in multiple languages with intelligent dictionary integration**

</div>

---

## ✨ Features

### 🌍 Multi-Language Support
- Manage vocabulary for unlimited languages
- English included by default
- Easy language creation and management
- Duplicate language prevention

### 📖 Smart Vocabulary Management
- **Auto-fill with Dictionary API** - Automatically fetch definitions, pronunciations, and usage examples for English words
- Store word, meaning, pronunciation, and optional notes
- Alphabetically sorted entries per language
- Duplicate word detection with update option
- Advanced search and filter functionality
- Swipe-to-delete entries
- Edit existing vocabulary entries

### 🎤 Audio Pronunciation Recording
- Record custom pronunciation for any word
- Playback recorded audio instantly
- Re-record capability for perfection
- Efficient file system storage
- Automatic cleanup when words are deleted
- Microphone permission handling

### 🤖 Dictionary API Integration (NEW!)
- **One-tap auto-fill** for English words
- Fetches from [Free Dictionary API](https://dictionaryapi.dev/)
- Automatically populates:
  - **Meaning**: Primary definition
  - **Pronunciation**: IPA phonetic notation
  - **Notes**: Part of speech, examples, synonyms, and antonyms
- Loading states and comprehensive error handling
- Only available for English language (smart detection)

### 📊 CSV Export
- Export complete vocabulary lists to CSV format
- Table-formatted output for easy import to spreadsheets
- Special character handling (quotes, commas, newlines)
- Share via AirDrop, Files, Email, and more
- Filename includes language name and timestamp

### 🎨 Beautiful Dark Theme
- Pure black background optimized for OLED displays
- Purple and pink gradient accents
- Cyan highlights for interactive elements
- Smooth animations and transitions
- Large, accessible UI components

---

## 📱 Screenshots

*Coming soon - screenshots showcasing the app in action*

---

## 🛠 Tech Stack

- **UI Framework**: SwiftUI 4.0+
- **Data Persistence**: Core Data
- **Audio Recording**: AVFoundation
- **Architecture**: MVVM (Model-View-ViewModel)
- **API Integration**: URLSession with async/await
- **iOS Version**: 16.0+
- **Language**: Swift 5.7+

**Zero third-party dependencies!** 🎉

---

## 📂 Project Structure

```
Leevda/
├── New Group/
│   ├── Leevda/
│   │   ├── LeevdaApp.swift                    # App entry point
│   │   ├── Assets.xcassets/                   # App icons and assets
│   │   └── Leevda.xcdatamodeld/              # Core Data model
│   │
│   ├── Models/
│   │   ├── PersistenceController.swift        # Core Data stack
│   │   └── CoreDataModel.md                   # Model documentation
│   │
│   ├── ViewModels/
│   │   ├── LanguageViewModel.swift            # Language CRUD logic
│   │   ├── VocabularyViewModel.swift          # Vocabulary CRUD logic
│   │   ├── AudioRecorderViewModel.swift       # Audio state management
│   │   ├── CSVExportViewModel.swift           # Export coordination
│   │   └── ImportViewModel.swift              # Import functionality
│   │
│   ├── Views/
│   │   ├── LanguageSelectionView.swift        # Main language list
│   │   ├── VocabularyListView.swift           # Word list with FAB
│   │   ├── AddEditWordView.swift              # Add/edit form with FILL button
│   │   ├── AudioRecorderView.swift            # Recording UI
│   │   └── AudioPlayerView.swift              # Playback UI
│   │
│   ├── Services/
│   │   ├── DictionaryAPIService.swift         # Dictionary API integration
│   │   ├── AudioService.swift                 # AVFoundation wrapper
│   │   ├── FileStorageService.swift           # Audio file management
│   │   ├── CSVExportService.swift             # CSV generation
│   │   └── CSVImportService.swift             # CSV import
│   │
│   └── Utilities/
│       ├── Theme.swift                        # Dark theme constants
│       └── Extensions/
│           └── Color+Theme.swift              # Color extensions
│
├── .gitignore                                 # Git ignore rules
└── README.md                                  # This file
```

---

## 🚀 Getting Started

### Prerequisites

- macOS Ventura or later
- Xcode 14.0 or later
- iPhone running iOS 16.0+ (for testing)
- Apple Developer Account (free tier is sufficient)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Leevda.git
   cd Leevda
   ```

2. **Open the project**
   ```bash
   open Leevda.xcodeproj
   ```

3. **Configure signing**
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Select your development team

4. **Run on device**
   - Connect your iPhone via USB
   - Select your device from the scheme dropdown
   - Press ⌘R to build and run

### First Run Setup

On first launch, you may need to trust the developer certificate:

1. Go to **Settings** → **General** → **VPN & Device Management**
2. Tap on your developer profile
3. Tap **Trust**

---

## 📖 Usage Guide

### Adding a Language

1. Launch the app
2. Tap **"Add New Language"** button
3. Enter the language name (e.g., "Spanish", "French")
4. Tap **"Add Language"**

> **Note**: English is automatically created on first launch.

### Adding Vocabulary (Manual Entry)

1. Tap a language to open its vocabulary list
2. Tap the large **+** button (bottom-right corner)
3. Fill in the form:
   - **Word** (required)
   - **Meaning** (required)
   - **Pronunciation** (optional)
   - **Note** (optional)
4. Optionally record audio pronunciation
5. Tap **"Save Word"**

### Adding Vocabulary (Auto-Fill) 🆕

**For English words only:**

1. Tap **English** language
2. Tap the **+** button
3. Type a word in the **Word** field (e.g., "serendipity")
4. Tap the **FILL** button next to the word field
5. Watch as the app automatically fills:
   - **Meaning**: "The occurrence of events by chance in a happy way"
   - **Pronunciation**: "/ˌserənˈdɪpɪti/"
   - **Note**: Part of speech, examples, synonyms, antonyms
6. Review and edit if needed
7. Tap **"Save Word"**

### Recording Audio Pronunciation

1. While adding/editing a word, scroll to **"Record Pronunciation"**
2. Tap **"Start Recording"**
3. Speak the word clearly
4. Tap **"Stop Recording"**
5. Tap **"Play"** to verify
6. Re-record if needed by tapping **"Record Again"**

### Editing a Word

1. Tap on any word in the vocabulary list
2. Modify any field
3. Tap **"Update Word"**

### Deleting a Word

- Swipe left on any word
- Tap **"Delete"**

### Searching

- Use the search bar at the top of the vocabulary list
- Search works across word, meaning, and pronunciation fields
- Results filter in real-time

### Exporting to CSV

1. Open any language's vocabulary list
2. Tap the **⋯** menu button (top-right)
3. Tap **"Export CSV"**

---

## 🔧 API Integration

### Dictionary API

The app uses the free [Dictionary API](https://dictionaryapi.dev/) for fetching word definitions.

**Endpoint:**
```
GET https://api.dictionaryapi.dev/api/v2/entries/en/{word}
```

**Features:**
- No API key required
- Returns comprehensive word data:
  - Definitions (multiple if available)
  - Phonetic pronunciations (IPA notation)
  - Part of speech (noun, verb, adjective, etc.)
  - Usage examples
  - Synonyms and antonyms
  - Audio pronunciation URLs

**Implementation Highlights:**
- Async/await for modern Swift concurrency
- Proper error handling for network failures
- Word not found detection
- User-friendly error messages
- Loading states with progress indicator

**Code Example:**
```swift
let wordData = try await DictionaryAPIService.shared.fetchWordDefinition(word: "example")
// Returns: WordData(word, meaning, pronunciation, note)
```

---

## 🏗 Architecture

### MVVM Pattern

```
┌─────────────────┐
│  Views (SwiftUI) │ ← User interactions
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   ViewModels     │ ← Business logic, @Published state
└────────┬────────┘
         │
         ↓
┌─────────────────┐  ┌─────────────────┐
│  Models (Core    │  │  Services       │
│  Data Entities)  │  │  (API, Audio,   │
│                  │  │   File, Export) │
└─────────────────┘  └─────────────────┘
```

### Data Model

**Language Entity:**
```swift
Language {
    id: UUID
    name: String
    sortOrder: Int16
    createdAt: Date
    vocabularyEntries: [VocabularyEntry] // One-to-Many
}
```

**VocabularyEntry Entity:**
```swift
VocabularyEntry {
    id: UUID
    word: String
    meaning: String
    pronunciation: String
    note: String?
    audioFileName: String?
    createdAt: Date
    updatedAt: Date
    language: Language // Many-to-One
}
```

**Relationships:**
- Language → VocabularyEntry: **One-to-Many** (cascade delete)
- VocabularyEntry → Language: **Many-to-One** (nullify on delete)

---

## ⚙️ Key Features Implementation

### Duplicate Detection
```swift
// Case-insensitive check using NSPredicate
NSPredicate(format: "word ==[c] %@ AND language == %@", word, language)
```

### Alphabetical Sorting
```swift
NSSortDescriptor(keyPath: \VocabularyEntry.word, ascending: true)
```

### Audio File Management
- Files stored in Documents directory
- Naming convention: `{entryID}.m4a`
- Automatic cleanup on entry deletion
- Optimized storage (not in database)

### CSV Export Format
- RFC 4180 compliant
- Proper field escaping for quotes, commas, newlines
- Headers: Word, Meaning, Pronunciation, Note
- Filename: `{LanguageName}_Vocabulary_{Timestamp}.csv`

---

## 🐛 Known Issues

- Dictionary API only supports English words
- iPad layout not yet optimized
- No iCloud backup (local storage only)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

- GitHub: [@canberkeh](https://github.com/canberkeh)

---

## 🙏 Acknowledgments

- [Free Dictionary API](https://dictionaryapi.dev/) for providing the dictionary service
- Apple's SwiftUI and Core Data frameworks
- All open-source contributors who inspire better coding practices

---

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/canberkeh/Leevda/issues) page
2. Open a new issue with detailed description
3. Include iOS version, Xcode version, and steps to reproduce

---

<div align="center">

  ⭐ Star this repo if you find it helpful!

</div>
