//
//  VocabularyViewModel.swift
//  Leevda
//
//  ViewModel for managing vocabulary entries (CRUD operations, search, duplicate detection)
//

import CoreData
import SwiftUI

class VocabularyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var entries: [VocabularyEntry] = []
    @Published var searchText = ""
    @Published var showDuplicateAlert = false
    @Published var duplicateEntry: VocabularyEntry?
    @Published var errorMessage: String?

    // MARK: - Properties
    let language: Language
    private let context: NSManagedObjectContext

    // MARK: - Computed Properties
    var filteredEntries: [VocabularyEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.word?.localizedCaseInsensitiveContains(searchText) == true ||
                entry.meaning?.localizedCaseInsensitiveContains(searchText) == true ||
                entry.pronunciation?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }

    // MARK: - Initialization
    init(language: Language, context: NSManagedObjectContext) {
        self.language = language
        self.context = context
        fetchEntries()
    }

    // MARK: - Fetch Entries
    func fetchEntries() {
        let request = VocabularyEntry.fetchRequest()
        request.predicate = NSPredicate(format: "language == %@", language)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \VocabularyEntry.word, ascending: true)
        ]

        do {
            entries = try context.fetch(request)
        } catch {
            errorMessage = "Failed to fetch vocabulary: \(error.localizedDescription)"
            print("Error fetching vocabulary entries: \(error)")
        }
    }

    // MARK: - Add Entry
    func addEntry(word: String, meaning: String, pronunciation: String, note: String?, audioFileName: String?) -> Result<VocabularyEntry, Error> {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMeaning = meaning.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate required fields
        guard !trimmedWord.isEmpty else {
            return .failure(ValidationError.emptyWord)
        }
        guard !trimmedMeaning.isEmpty else {
            return .failure(ValidationError.emptyMeaning)
        }

        // Check for duplicates
        if let existing = checkForDuplicate(word: trimmedWord) {
            duplicateEntry = existing
            showDuplicateAlert = true
            return .failure(ValidationError.duplicateWord)
        }

        // Create new entry
        let entry = VocabularyEntry(context: context)
        entry.id = UUID()
        entry.word = trimmedWord
        entry.meaning = trimmedMeaning
        entry.pronunciation = pronunciation.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.audioFileName = audioFileName
        entry.createdAt = Date()
        entry.updatedAt = Date()
        entry.language = language

        // Save context
        do {
            try context.save()
            fetchEntries() // Refresh list
            return .success(entry)
        } catch {
            errorMessage = "Failed to add word: \(error.localizedDescription)"
            print("Error adding vocabulary entry: \(error)")
            return .failure(error)
        }
    }

    // MARK: - Update Entry
    func updateEntry(_ entry: VocabularyEntry, word: String, meaning: String, pronunciation: String, note: String?, audioFileName: String?) {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMeaning = meaning.trimmingCharacters(in: .whitespacesAndNewlines)

        // If word changed, check for duplicates
        if trimmedWord.lowercased() != entry.word?.lowercased() {
            if let existing = checkForDuplicate(word: trimmedWord), existing != entry {
                duplicateEntry = existing
                showDuplicateAlert = true
                return
            }
        }

        // Update fields
        entry.word = trimmedWord
        entry.meaning = trimmedMeaning
        entry.pronunciation = pronunciation.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.audioFileName = audioFileName
        entry.updatedAt = Date()

        // Save context
        do {
            try context.save()
            fetchEntries() // Refresh list
        } catch {
            errorMessage = "Failed to update word: \(error.localizedDescription)"
            print("Error updating vocabulary entry: \(error)")
        }
    }

    // MARK: - Delete Entry
    func deleteEntry(_ entry: VocabularyEntry) {
        // Delete associated audio file if it exists
        if let audioFileName = entry.audioFileName {
            FileStorageService.shared.deleteAudioFile(fileName: audioFileName)
        }

        // Delete from Core Data
        context.delete(entry)

        do {
            try context.save()
            fetchEntries() // Refresh list
        } catch {
            errorMessage = "Failed to delete word: \(error.localizedDescription)"
            print("Error deleting vocabulary entry: \(error)")
        }
    }

    // MARK: - Check for Duplicate
    func checkForDuplicate(word: String) -> VocabularyEntry? {
        let request = VocabularyEntry.fetchRequest()
        request.predicate = NSPredicate(
            format: "word ==[c] %@ AND language == %@",
            word,
            language
        )
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print("Error checking for duplicate word: \(error)")
            return nil
        }
    }

    // MARK: - Helper Methods
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Validation Errors
enum ValidationError: LocalizedError {
    case emptyWord
    case emptyMeaning
    case duplicateWord

    var errorDescription: String? {
        switch self {
        case .emptyWord:
            return "Word cannot be empty"
        case .emptyMeaning:
            return "Meaning cannot be empty"
        case .duplicateWord:
            return "This word already exists"
        }
    }
}
