//
//  CSVExportService.swift
//  Leevda
//
//  Service for generating CSV exports from vocabulary entries
//

import Foundation

class CSVExportService {
    // MARK: - CSV Generation
    func generateCSV(from entries: [VocabularyEntry], includeAudio: Bool = false) -> String {
        var csv: String

        if includeAudio {
            csv = "Word,Meaning,Pronunciation,Note,AudioFileName\n"
        } else {
            csv = "Word,Meaning,Pronunciation,Note\n"
        }

        // Sort alphabetically by word
        let sortedEntries = entries.sorted { ($0.word ?? "") < ($1.word ?? "") }

        for entry in sortedEntries {
            let word = escapeCSVField(entry.word ?? "")
            let meaning = escapeCSVField(entry.meaning ?? "")
            let pronunciation = escapeCSVField(entry.pronunciation ?? "")
            let note = escapeCSVField(entry.note ?? "")

            if includeAudio {
                let audioFileName = escapeCSVField(entry.audioFileName ?? "")
                csv += "\(word),\(meaning),\(pronunciation),\(note),\(audioFileName)\n"
            } else {
                csv += "\(word),\(meaning),\(pronunciation),\(note)\n"
            }
        }

        return csv
    }

    // MARK: - CSV Field Escaping
    private func escapeCSVField(_ field: String) -> String {
        // If field contains comma, double quote, or newline, wrap in quotes
        // and escape any existing quotes by doubling them
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedField)\""
        }
        return field
    }

    // MARK: - Export to File (CSV only)
    func exportToFile(entries: [VocabularyEntry], languageName: String) -> Result<URL, Error> {
        let csv = generateCSV(from: entries, includeAudio: false)

        // Create filename with date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "Leevda_\(languageName)_\(dateString).csv"

        // Get temporary directory URL
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            // Write CSV to temporary file
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            return .success(tempURL)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Export to ZIP (CSV + Audio files)
    func exportToZIP(entries: [VocabularyEntry], languageName: String) -> Result<URL, Error> {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory

        // Create unique export folder
        let exportFolderName = UUID().uuidString
        let exportFolder = tempDir.appendingPathComponent(exportFolderName)

        do {
            // Create export folder
            try fileManager.createDirectory(at: exportFolder, withIntermediateDirectories: true)

            // 1. Write CSV file
            let csv = generateCSV(from: entries, includeAudio: true)
            let csvURL = exportFolder.appendingPathComponent("vocabulary.csv")
            try csv.write(to: csvURL, atomically: true, encoding: .utf8)

            // 2. Copy audio files
            let audioFolder = exportFolder.appendingPathComponent("Audio")
            try fileManager.createDirectory(at: audioFolder, withIntermediateDirectories: true)

            var copiedCount = 0
            for entry in entries {
                guard let audioFileName = entry.audioFileName else { continue }

                let sourceURL = FileStorageService.shared.getAudioFileURL(for: audioFileName)
                let destURL = audioFolder.appendingPathComponent(audioFileName)

                if fileManager.fileExists(atPath: sourceURL.path) {
                    try fileManager.copyItem(at: sourceURL, to: destURL)
                    copiedCount += 1
                }
            }

            print("✓ Copied \(copiedCount) audio files")

            // 3. Create ZIP file
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
            let zipFileName = "Leevda_\(languageName)_\(dateString).zip"
            let zipURL = tempDir.appendingPathComponent(zipFileName)

            // Remove existing ZIP if any
            if fileManager.fileExists(atPath: zipURL.path) {
                try fileManager.removeItem(at: zipURL)
            }

            // Create ZIP using Compression framework
            try createZIPArchive(sourceURL: exportFolder, destinationURL: zipURL)

            // Clean up export folder
            try? fileManager.removeItem(at: exportFolder)

            return .success(zipURL)

        } catch {
            // Clean up on error
            try? fileManager.removeItem(at: exportFolder)
            return .failure(error)
        }
    }

    // MARK: - ZIP Creation using native iOS compression
    private func createZIPArchive(sourceURL: URL, destinationURL: URL) throws {
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        var zipCreated = false

        coordinator.coordinate(readingItemAt: sourceURL, options: [.forUploading], error: &coordinatorError) { zippedURL in
            do {
                // The coordinator automatically creates a ZIP when using .forUploading
                if FileManager.default.fileExists(atPath: zippedURL.path) {
                    try FileManager.default.copyItem(at: zippedURL, to: destinationURL)
                    zipCreated = true
                }
            } catch {
                print("Error moving ZIP: \(error)")
            }
        }

        if let error = coordinatorError {
            throw error
        }

        if !zipCreated {
            throw ExportError.zipCreationFailed
        }
    }
}

// MARK: - Export Errors
enum ExportError: LocalizedError {
    case zipCreationFailed

    var errorDescription: String? {
        switch self {
        case .zipCreationFailed:
            return "Failed to create ZIP archive"
        }
    }
}
