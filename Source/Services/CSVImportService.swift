//
//  CSVImportService.swift
//  Leevda
//
//  Service for importing CSV files and audio back into the app
//

import Foundation
import CoreData

class CSVImportService {
    // MARK: - Import Result
    struct ImportResult {
        let addedCount: Int
        let updatedCount: Int
        let skippedCount: Int
        let audioImportedCount: Int
    }

    // MARK: - Import from CSV file
    func importCSV(from url: URL, to language: Language, context: NSManagedObjectContext) -> Result<ImportResult, Error> {
        do {
            // Read CSV file
            let csvContent = try String(contentsOf: url, encoding: .utf8)
            let lines = csvContent.components(separatedBy: .newlines).filter { !$0.isEmpty }

            guard lines.count > 1 else {
                return .failure(ImportError.emptyFile)
            }

            // Parse header
            let header = lines[0].components(separatedBy: ",")
            let hasAudioColumn = header.count == 5 && header.last?.contains("Audio") == true

            var addedCount = 0
            var updatedCount = 0
            var skippedCount = 0

            // Parse data rows (skip header)
            for i in 1..<lines.count {
                let line = lines[i]
                let fields = parseCSVLine(line)

                guard fields.count >= 4 else {
                    skippedCount += 1
                    continue
                }

                let word = fields[0]
                let meaning = fields[1]
                let pronunciation = fields[2]
                let note = fields[3].isEmpty ? nil : fields[3]
                let audioFileName = hasAudioColumn && fields.count > 4 && !fields[4].isEmpty ? fields[4] : nil

                // Check for duplicate
                if let existing = findExistingEntry(word: word, language: language, context: context) {
                    // Update existing
                    existing.meaning = meaning
                    existing.pronunciation = pronunciation
                    existing.note = note
                    existing.audioFileName = audioFileName
                    existing.updatedAt = Date()
                    updatedCount += 1
                } else {
                    // Create new entry
                    let entry = VocabularyEntry(context: context)
                    entry.id = UUID()
                    entry.word = word
                    entry.meaning = meaning
                    entry.pronunciation = pronunciation
                    entry.note = note
                    entry.audioFileName = audioFileName
                    entry.createdAt = Date()
                    entry.updatedAt = Date()
                    entry.language = language
                    addedCount += 1
                }
            }

            // Save context
            try context.save()

            return .success(ImportResult(
                addedCount: addedCount,
                updatedCount: updatedCount,
                skippedCount: skippedCount,
                audioImportedCount: 0
            ))

        } catch {
            return .failure(error)
        }
    }

    // MARK: - Import from ZIP file (CSV + Audio)
    func importZIP(from url: URL, to language: Language, context: NSManagedObjectContext) -> Result<ImportResult, Error> {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory

        // Create unique import folder
        let importFolderName = UUID().uuidString
        let importFolder = tempDir.appendingPathComponent(importFolderName)

        do {
            // Create import folder
            try fileManager.createDirectory(at: importFolder, withIntermediateDirectories: true)

            // Extract ZIP using NSFileCoordinator
            try extractZIPArchive(sourceURL: url, destinationURL: importFolder)

            // Find CSV file
            guard let csvURL = findCSVFile(in: importFolder) else {
                try? fileManager.removeItem(at: importFolder)
                return .failure(ImportError.csvNotFound)
            }

            // Import CSV
            let csvResult = importCSV(from: csvURL, to: language, context: context)

            guard case .success(var result) = csvResult else {
                try? fileManager.removeItem(at: importFolder)
                return csvResult
            }

            // Import audio files
            let audioFolder = findAudioFolder(in: importFolder)
            var audioImportedCount = 0

            if let audioFolder = audioFolder {
                let audioFiles = try fileManager.contentsOfDirectory(at: audioFolder, includingPropertiesForKeys: nil)

                for audioFile in audioFiles {
                    let destinationURL = FileStorageService.shared.getAudioFileURL(for: audioFile.lastPathComponent)

                    // Skip if already exists
                    if !fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.copyItem(at: audioFile, to: destinationURL)
                        audioImportedCount += 1
                    }
                }
            }

            // Clean up import folder
            try? fileManager.removeItem(at: importFolder)

            result = ImportResult(
                addedCount: result.addedCount,
                updatedCount: result.updatedCount,
                skippedCount: result.skippedCount,
                audioImportedCount: audioImportedCount
            )

            return .success(result)

        } catch {
            try? fileManager.removeItem(at: importFolder)
            return .failure(error)
        }
    }

    // MARK: - Helper Methods
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        fields.append(currentField.trimmingCharacters(in: .whitespaces))
        return fields
    }

    private func findExistingEntry(word: String, language: Language, context: NSManagedObjectContext) -> VocabularyEntry? {
        let request = VocabularyEntry.fetchRequest()
        request.predicate = NSPredicate(format: "word ==[c] %@ AND language == %@", word, language)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    private func findCSVFile(in directory: URL) -> URL? {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return nil
        }

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension.lowercased() == "csv" {
                return fileURL
            }
        }

        return nil
    }

    private func findAudioFolder(in directory: URL) -> URL? {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return nil
        }

        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]),
               resourceValues.isDirectory == true,
               fileURL.lastPathComponent.lowercased() == "audio" {
                return fileURL
            }
        }

        return nil
    }

    private func extractZIPArchive(sourceURL: URL, destinationURL: URL) throws {
        // Note: ZIP import is not yet implemented on iOS
        // User should manually extract ZIP and import the CSV file
        throw ImportError.zipNotSupported
    }
}

// MARK: - Import Errors
enum ImportError: LocalizedError {
    case emptyFile
    case zipExtractionFailed
    case csvNotFound
    case invalidFormat
    case zipNotSupported

    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "CSV file is empty"
        case .zipExtractionFailed:
            return "Failed to extract ZIP archive"
        case .csvNotFound:
            return "CSV file not found in archive"
        case .invalidFormat:
            return "Invalid CSV format"
        case .zipNotSupported:
            return "ZIP import not yet supported. Please extract the ZIP manually and import the CSV file."
        }
    }
}
