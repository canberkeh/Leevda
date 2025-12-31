//
//  LanguageViewModel.swift
//  Leevda
//
//  ViewModel for managing languages (CRUD operations)
//

import CoreData
import SwiftUI

class LanguageViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var languages: [Language] = []
    @Published var showDuplicateAlert = false
    @Published var duplicateLanguageName = ""
    @Published var showAddLanguageSheet = false
    @Published var newLanguageName = ""
    @Published var newLanguageEmoji = ""
    @Published var showEditEmojiSheet = false
    @Published var selectedLanguage: Language?
    @Published var editingEmoji = ""
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let context: NSManagedObjectContext

    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchLanguages()
    }

    // MARK: - Fetch Languages
    func fetchLanguages() {
        let request = Language.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Language.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Language.name, ascending: true)
        ]

        do {
            languages = try context.fetch(request)
        } catch {
            errorMessage = "Failed to fetch languages: \(error.localizedDescription)"
            print("Error fetching languages: \(error)")
        }
    }

    // MARK: - Add Language
    func addLanguage(name: String, customEmoji: String? = nil) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate input
        guard !trimmedName.isEmpty else {
            errorMessage = "Language name cannot be empty"
            return false
        }

        // Check for duplicates (case-insensitive)
        if languageExists(name: trimmedName) {
            duplicateLanguageName = trimmedName
            showDuplicateAlert = true
            return false
        }

        // Create new language
        let language = Language(context: context)
        language.id = UUID()
        language.name = trimmedName
        language.createdAt = Date()

        // Set emoji: custom if provided, otherwise auto-detect from FlagService
        if let custom = customEmoji?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
            language.emoji = custom
        } else {
            language.emoji = FlagService.shared.getFlag(for: trimmedName)
        }

        // Calculate sort order (0 for English, incrementing for others)
        if trimmedName.lowercased() == "english" {
            language.sortOrder = 0
        } else {
            // Find max sort order and add 1
            let maxSort = languages.map { $0.sortOrder }.max() ?? 0
            language.sortOrder = maxSort + 1
        }

        // Save context
        do {
            try context.save()
            fetchLanguages() // Refresh list
            return true
        } catch {
            errorMessage = "Failed to add language: \(error.localizedDescription)"
            print("Error adding language: \(error)")
            return false
        }
    }

    // MARK: - Update Language Emoji
    func updateLanguageEmoji(_ language: Language, emoji: String) {
        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        language.emoji = trimmedEmoji.isEmpty ? FlagService.shared.getFlag(for: language.name ?? "") : trimmedEmoji

        do {
            try context.save()
            fetchLanguages() // Refresh list
        } catch {
            errorMessage = "Failed to update emoji: \(error.localizedDescription)"
            print("Error updating emoji: \(error)")
        }
    }

    // MARK: - Delete Language
    func deleteLanguage(_ language: Language) {
        context.delete(language)

        do {
            try context.save()
            fetchLanguages() // Refresh list
        } catch {
            errorMessage = "Failed to delete language: \(error.localizedDescription)"
            print("Error deleting language: \(error)")
        }
    }

    // MARK: - Check for Duplicate
    func languageExists(name: String) -> Bool {
        let request = Language.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            print("Error checking for duplicate language: \(error)")
            return false
        }
    }

    // MARK: - Helper Methods
    func clearError() {
        errorMessage = nil
    }

    func resetNewLanguageForm() {
        newLanguageName = ""
        newLanguageEmoji = ""
        showAddLanguageSheet = false
    }

    // MARK: - Edit Emoji Methods
    func openEmojiEditor(for language: Language) {
        selectedLanguage = language
        editingEmoji = language.emoji ?? ""
        showEditEmojiSheet = true
    }

    func saveEditedEmoji() {
        guard let language = selectedLanguage else { return }
        updateLanguageEmoji(language, emoji: editingEmoji)
        closeEmojiEditor()
    }

    func closeEmojiEditor() {
        selectedLanguage = nil
        editingEmoji = ""
        showEditEmojiSheet = false
    }
}
