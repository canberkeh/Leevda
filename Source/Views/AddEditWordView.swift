//
//  AddEditWordView.swift
//  Leevda
//
//  Form for adding or editing vocabulary entries with audio recording
//

import SwiftUI

struct AddEditWordView: View {
    let language: Language
    @ObservedObject var viewModel: VocabularyViewModel
    let existingEntry: VocabularyEntry?

    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioViewModel = AudioRecorderViewModel()

    // Form fields
    @State private var word = ""
    @State private var meaning = ""
    @State private var pronunciation = ""
    @State private var note = ""

    // UI State
    @State private var showingSaveError = false
    @State private var errorMessage = ""
    @State private var isLoadingDefinition = false
    @State private var showDictionaryError = false
    @State private var dictionaryErrorMessage = ""

    var isEditing: Bool {
        existingEntry != nil
    }

    var isEnglish: Bool {
        language.name?.lowercased() == "english"
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    // Form Header
                    VStack(spacing: 6) {
                        Text(isEditing ? "Edit Word" : "Add New Word")
                            .font(.title2.bold())
                            .foregroundColor(.appTextPrimary)

                        Text(language.name ?? "")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.top, 8)

                    // Form Fields
                    VStack(spacing: 12) {
                        // Word Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Word")
                                .font(.caption.bold())
                                .foregroundColor(.appTextSecondary)

                            HStack(spacing: 8) {
                                TextField("Enter word", text: $word)
                                    .textFieldStyle(CustomTextFieldStyle())

                                // FILL button (only for English language)
                                if isEnglish {
                                    Button {
                                        fetchDefinition()
                                    } label: {
                                        if isLoadingDefinition {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .frame(width: 50, height: 44)
                                        } else {
                                            Text("FILL")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                                .frame(width: 50, height: 44)
                                        }
                                    }
                                    .background(
                                        word.isEmpty ? Color.gray : Color.appAccentPurple
                                    )
                                    .cornerRadius(AppTheme.cornerRadiusMedium)
                                    .disabled(word.isEmpty || isLoadingDefinition)
                                }
                            }
                        }

                        // Meaning Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Meaning")
                                .font(.caption.bold())
                                .foregroundColor(.appTextSecondary)

                            TextEditor(text: $meaning)
                                .frame(height: 80)
                                .padding(12)
                                .background(AppTheme.secondaryBackground)
                                .cornerRadius(AppTheme.cornerRadiusMedium)
                                .foregroundColor(.appTextPrimary)
                                .scrollContentBackground(.hidden)
                        }

                        // Pronunciation Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pronunciation (optional)")
                                .font(.caption.bold())
                                .foregroundColor(.appTextSecondary)

                            TextField("Enter pronunciation", text: $pronunciation)
                                .textFieldStyle(CustomTextFieldStyle())
                        }

                        // Note Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note (optional)")
                                .font(.caption.bold())
                                .foregroundColor(.appTextSecondary)

                            TextEditor(text: $note)
                                .frame(height: 80)
                                .padding(12)
                                .background(AppTheme.secondaryBackground)
                                .cornerRadius(AppTheme.cornerRadiusMedium)
                                .foregroundColor(.appTextPrimary)
                                .scrollContentBackground(.hidden)
                        }

                        // Audio Recording Section
                        AudioRecorderView(
                            viewModel: audioViewModel,
                            entryID: existingEntry?.id ?? UUID()
                        )
                    }
                    .padding(.horizontal, AppTheme.paddingMedium)

                    // Save Button
                    Button {
                        saveEntry()
                    } label: {
                        Text(isEditing ? "Update Word" : "Save Word")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                (word.isEmpty || meaning.isEmpty) ?
                                    AnyShapeStyle(Color.gray) :
                                    AnyShapeStyle(AppTheme.primaryGradient)
                            )
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                    .disabled(word.isEmpty || meaning.isEmpty)
                    .padding(.horizontal, AppTheme.paddingMedium)

                    Spacer(minLength: 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Cancel") {
                    dismiss()
                }
                .foregroundColor(.appAccentPurple)
            }
        }
        .alert("Duplicate Word", isPresented: $viewModel.showDuplicateAlert) {
            Button("Cancel", role: .cancel) {}
            if let duplicate = viewModel.duplicateEntry {
                Button("View Existing") {
                    // Load existing entry data
                    loadEntryData(duplicate)
                }
                Button("Update") {
                    updateDuplicateEntry(duplicate)
                }
            }
        } message: {
            Text("'\(word)' already exists in \(language.name ?? "this language"). Would you like to view or update it?")
        }
        .alert("Error", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Dictionary Error", isPresented: $showDictionaryError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(dictionaryErrorMessage)
        }
        .onAppear {
            if let entry = existingEntry {
                loadEntryData(entry)
            }
        }
    }

    // MARK: - Dictionary API Functions
    private func fetchDefinition() {
        guard !word.isEmpty else { return }

        isLoadingDefinition = true

        Task {
            do {
                let wordData = try await DictionaryAPIService.shared.fetchWordDefinition(word: word)

                // Update UI on main thread
                await MainActor.run {
                    meaning = wordData.meaning
                    pronunciation = wordData.pronunciation
                    note = wordData.note
                    isLoadingDefinition = false
                }
            } catch {
                await MainActor.run {
                    dictionaryErrorMessage = error.localizedDescription
                    showDictionaryError = true
                    isLoadingDefinition = false
                }
            }
        }
    }

    // MARK: - Helper Functions
    private func loadEntryData(_ entry: VocabularyEntry) {
        word = entry.word ?? ""
        meaning = entry.meaning ?? ""
        pronunciation = entry.pronunciation ?? ""
        note = entry.note ?? ""

        // Load existing audio if available
        if let audioFileName = entry.audioFileName {
            audioViewModel.loadExistingRecording(fileName: audioFileName)
        }
    }

    private func saveEntry() {
        if isEditing, let entry = existingEntry {
            // Update existing entry
            viewModel.updateEntry(
                entry,
                word: word,
                meaning: meaning,
                pronunciation: pronunciation,
                note: note.isEmpty ? nil : note,
                audioFileName: audioViewModel.audioFileName
            )
            dismiss()
        } else {
            // Add new entry
            let result = viewModel.addEntry(
                word: word,
                meaning: meaning,
                pronunciation: pronunciation,
                note: note.isEmpty ? nil : note,
                audioFileName: audioViewModel.audioFileName
            )

            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                if error as? ValidationError != .duplicateWord {
                    errorMessage = error.localizedDescription
                    showingSaveError = true
                }
            }
        }
    }

    private func updateDuplicateEntry(_ entry: VocabularyEntry) {
        viewModel.updateEntry(
            entry,
            word: word,
            meaning: meaning,
            pronunciation: pronunciation,
            note: note.isEmpty ? nil : note,
            audioFileName: audioViewModel.audioFileName
        )
        dismiss()
    }
}

// MARK: - Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.secondaryBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .foregroundColor(.appTextPrimary)
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        AddEditWordView(
            language: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Language }) as! Language,
            viewModel: VocabularyViewModel(
                language: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Language }) as! Language,
                context: PersistenceController.preview.container.viewContext
            ),
            existingEntry: nil
        )
    }
    .preferredColorScheme(.dark)
}
