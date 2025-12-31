//
//  LanguageSelectionView.swift
//  Leevda
//
//  Main screen for selecting languages with grid layout
//

import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: LanguageViewModel

    init() {
        _viewModel = StateObject(wrappedValue: LanguageViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.paddingLarge) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Leevda")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryGradient)

                            Text("Vocabulary Learning")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.top, AppTheme.paddingLarge)

                        // Language Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(viewModel.languages, id: \.id) { language in
                                NavigationLink(destination: VocabularyListView(language: language)) {
                                    LanguageButton(
                                        languageName: language.name ?? "",
                                        emoji: language.emoji ?? FlagService.shared.getFlag(for: language.name ?? "")
                                    )
                                }
                                .contextMenu {
                                    Button {
                                        viewModel.openEmojiEditor(for: language)
                                    } label: {
                                        Label("Edit Emoji", systemImage: "face.smiling")
                                    }

                                    Button(role: .destructive) {
                                        viewModel.deleteLanguage(language)
                                    } label: {
                                        Label("Delete Language", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.paddingMedium)

                        // Add Language Button
                        Button {
                            viewModel.showAddLanguageSheet = true
                        } label: {
                            Label("Add New Language", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.tertiaryBackground)
                                .cornerRadius(AppTheme.cornerRadiusMedium)
                        }
                        .padding(.horizontal, AppTheme.paddingMedium)
                        .padding(.top, AppTheme.paddingSmall)
                    }
                    .padding(.bottom, AppTheme.paddingLarge)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showAddLanguageSheet) {
            AddLanguageSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditEmojiSheet) {
            EditEmojiSheet(viewModel: viewModel)
        }
        .alert("Language Already Exists", isPresented: $viewModel.showDuplicateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("'\(viewModel.duplicateLanguageName)' is already in your language list.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onAppear {
            viewModel.fetchLanguages()
        }
    }
}

// MARK: - Language Button Component
struct LanguageButton: View {
    let languageName: String
    let emoji: String

    var body: some View {
        VStack(spacing: 12) {
            // Flag/Emoji Display
            Text(emoji)
                .font(.system(size: 56))
                .frame(width: 70, height: 70)

            Text(languageName)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(AppTheme.secondaryBackground)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .stroke(AppTheme.accentPurple.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Add Language Sheet
struct AddLanguageSheet: View {
    @ObservedObject var viewModel: LanguageViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: AppTheme.paddingLarge) {
                    Text("Add New Language")
                        .font(.title2.bold())
                        .foregroundColor(.appTextPrimary)
                        .padding(.top)

                    VStack(spacing: 16) {
                        TextField("Language Name", text: $viewModel.newLanguageName)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .foregroundColor(.appTextPrimary)
                            .autocapitalization(.words)

                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Emoji (optional)", text: $viewModel.newLanguageEmoji)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.secondaryBackground)
                                .cornerRadius(AppTheme.cornerRadiusMedium)
                                .foregroundColor(.appTextPrimary)
                                .font(.system(size: 32))
                                .multilineTextAlignment(.center)

                            Text("Leave empty for automatic flag")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        if viewModel.addLanguage(name: viewModel.newLanguageName, customEmoji: viewModel.newLanguageEmoji) {
                            viewModel.resetNewLanguageForm()
                            dismiss()
                        }
                    } label: {
                        Text("Add Language")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.newLanguageName.isEmpty ?
                                    AnyShapeStyle(Color.gray) :
                                    AnyShapeStyle(AppTheme.primaryGradient)
                            )
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                    .disabled(viewModel.newLanguageName.isEmpty)
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.resetNewLanguageForm()
                        dismiss()
                    }
                    .foregroundColor(.appAccentPurple)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Edit Emoji Sheet
struct EditEmojiSheet: View {
    @ObservedObject var viewModel: LanguageViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: AppTheme.paddingLarge) {
                    // Current Emoji Display
                    if let language = viewModel.selectedLanguage {
                        VStack(spacing: 12) {
                            Text("Edit Emoji for")
                                .font(.headline)
                                .foregroundColor(.appTextSecondary)

                            Text(language.name ?? "")
                                .font(.title.bold())
                                .foregroundColor(.appTextPrimary)

                            // Current emoji preview
                            Text(viewModel.editingEmoji.isEmpty ?
                                 FlagService.shared.getFlag(for: language.name ?? "") :
                                 viewModel.editingEmoji)
                                .font(.system(size: 80))
                                .padding()
                        }
                        .padding(.top)
                    }

                    VStack(spacing: 16) {
                        TextField("Emoji", text: $viewModel.editingEmoji)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .foregroundColor(.appTextPrimary)
                            .font(.system(size: 48))
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tips:")
                                .font(.caption.bold())
                                .foregroundColor(.appTextSecondary)

                            Text("• Leave empty to reset to automatic flag")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)

                            Text("• Use any emoji: 🎌 🤙 💻 📚 ⚙️")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    }
                    .padding(.horizontal)

                    // Save Button
                    Button {
                        viewModel.saveEditedEmoji()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.closeEmojiEditor()
                        dismiss()
                    }
                    .foregroundColor(.appAccentPurple)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Previews
#Preview {
    LanguageSelectionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
