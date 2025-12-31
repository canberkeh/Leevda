//
//  CSVExportViewModel.swift
//  Leevda
//
//  ViewModel for coordinating CSV export and sharing
//

import SwiftUI

class CSVExportViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isExporting = false
    @Published var exportURL: URL?
    @Published var showShareSheet = false
    @Published var showExportOptions = false
    @Published var errorMessage: String?

    // MARK: - Properties
    private let csvService = CSVExportService()

    // MARK: - Export with Options
    func showExportDialog() {
        showExportOptions = true
    }

    func exportCSVOnly(_ entries: [VocabularyEntry], languageName: String) {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let result = self.csvService.exportToFile(entries: entries, languageName: languageName)

            DispatchQueue.main.async {
                self.isExporting = false

                switch result {
                case .success(let url):
                    self.exportURL = url
                    self.showShareSheet = true
                case .failure(let error):
                    self.errorMessage = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func exportWithAudio(_ entries: [VocabularyEntry], languageName: String) {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let result = self.csvService.exportToZIP(entries: entries, languageName: languageName)

            DispatchQueue.main.async {
                self.isExporting = false

                switch result {
                case .success(let url):
                    self.exportURL = url
                    self.showShareSheet = true
                case .failure(let error):
                    self.errorMessage = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Legacy Export (for compatibility)
    func exportEntries(_ entries: [VocabularyEntry], languageName: String) {
        exportCSVOnly(entries, languageName: languageName)
    }

    // MARK: - Helpers
    func clearError() {
        errorMessage = nil
    }

    func cleanup() {
        // Clean up temporary export file after sharing
        if let url = exportURL {
            try? FileManager.default.removeItem(at: url)
            exportURL = nil
        }
    }
}
