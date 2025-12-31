//
//  ImportViewModel.swift
//  Leevda
//
//  ViewModel for coordinating CSV/ZIP import
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

class ImportViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isImporting = false
    @Published var showFilePicker = false
    @Published var showResultAlert = false
    @Published var resultMessage = ""
    @Published var errorMessage: String?

    // MARK: - Properties
    private let importService = CSVImportService()

    // MARK: - Import
    func importFile(from url: URL, to language: Language, context: NSManagedObjectContext) {
        isImporting = true

        // Start accessing security-scoped resource
        let didStartAccessing = url.startAccessingSecurityScopedResource()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let result: Result<CSVImportService.ImportResult, Error>

            // Detect file type
            if url.pathExtension.lowercased() == "zip" {
                result = self.importService.importZIP(from: url, to: language, context: context)
            } else {
                result = self.importService.importCSV(from: url, to: language, context: context)
            }

            // Stop accessing security-scoped resource
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }

            DispatchQueue.main.async {
                self.isImporting = false

                switch result {
                case .success(let importResult):
                    self.showSuccessMessage(importResult)
                case .failure(let error):
                    self.errorMessage = "Import failed: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func showSuccessMessage(_ result: CSVImportService.ImportResult) {
        var message = "Import Successful!\n\n"
        message += "✓ Added: \(result.addedCount) words\n"
        message += "✓ Updated: \(result.updatedCount) words\n"

        if result.skippedCount > 0 {
            message += "⚠️ Skipped: \(result.skippedCount) words\n"
        }

        if result.audioImportedCount > 0 {
            message += "🎵 Audio files: \(result.audioImportedCount)\n"
        }

        resultMessage = message
        showResultAlert = true
    }

    func clearError() {
        errorMessage = nil
    }
}
