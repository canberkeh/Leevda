//
//  VocabularyListView.swift
//  Leevda
//
//  List view for vocabulary entries with search and large FAB button
//

import SwiftUI
import UniformTypeIdentifiers

struct VocabularyListView: View {
    let language: Language

    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: VocabularyViewModel
    @StateObject private var csvViewModel = CSVExportViewModel()
    @StateObject private var importViewModel = ImportViewModel()
    @State private var showAddSheet = false
    @State private var showImportPicker = false

    init(language: Language) {
        self.language = language
        _viewModel = StateObject(wrappedValue: VocabularyViewModel(
            language: language,
            context: PersistenceController.shared.container.viewContext
        ))
    }

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.appTextSecondary)

                    TextField("Search words...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(.appTextPrimary)
                }
                .padding()
                .background(AppTheme.secondaryBackground)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .padding()

                // Word List
                if viewModel.filteredEntries.isEmpty {
                    EmptyStateView(searchText: viewModel.searchText)
                } else {
                    List {
                        ForEach(viewModel.filteredEntries, id: \.id) { entry in
                            NavigationLink(destination: AddEditWordView(
                                language: language,
                                viewModel: viewModel,
                                existingEntry: entry
                            )) {
                                WordRowView(entry: entry)
                            }
                            .listRowBackground(AppTheme.secondaryBackground)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                Spacer()
            }

            // Large FAB (Floating Action Button)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryGradient)
                                .frame(width: 70, height: 70)
                                .shadow(color: AppTheme.accentPurple.opacity(0.6), radius: 12, x: 0, y: 6)

                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(language.name ?? "Vocabulary")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Export Section
                    Button {
                        csvViewModel.exportCSVOnly(viewModel.entries, languageName: language.name ?? "Unknown")
                    } label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    }

                    // TODO: ZIP export will be added in future version
                    // Requires external ZIP library for iOS

                    // Import Section
                    Button {
                        showImportPicker = true
                    } label: {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }

                    Divider()

                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add New Word", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.appAccentPurple)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                AddEditWordView(
                    language: language,
                    viewModel: viewModel,
                    existingEntry: nil
                )
            }
        }
        .sheet(isPresented: $csvViewModel.showShareSheet) {
            if let url = csvViewModel.exportURL {
                ShareSheet(items: [url])
                    .onDisappear {
                        csvViewModel.cleanup()
                    }
            }
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [UTType(filenameExtension: "csv")!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importViewModel.importFile(from: url, to: language, context: context)
                }
            case .failure(let error):
                importViewModel.errorMessage = "File selection failed: \(error.localizedDescription)"
            }
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
        .alert("Import Error", isPresented: .constant(importViewModel.errorMessage != nil)) {
            Button("OK") {
                importViewModel.clearError()
            }
        } message: {
            if let error = importViewModel.errorMessage {
                Text(error)
            }
        }
        .alert("Import Result", isPresented: $importViewModel.showResultAlert) {
            Button("OK") {
                viewModel.fetchEntries() // Refresh list
            }
        } message: {
            Text(importViewModel.resultMessage)
        }
        .overlay {
            if importViewModel.isImporting || csvViewModel.isExporting {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)

                        Text(importViewModel.isImporting ? "Importing..." : "Exporting...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(AppTheme.secondaryBackground)
                    .cornerRadius(AppTheme.cornerRadiusLarge)
                }
            }
        }
        .onAppear {
            viewModel.fetchEntries()
        }
    }

    // MARK: - Helper Functions
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = viewModel.filteredEntries[index]
            viewModel.deleteEntry(entry)
        }
    }

    private func exportToCSV() {
        csvViewModel.exportEntries(viewModel.entries, languageName: language.name ?? "Unknown")
    }
}

// MARK: - Word Row Component
struct WordRowView: View {
    let entry: VocabularyEntry

    var body: some View {
        HStack(spacing: 12) {
            // Word and Pronunciation
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.word ?? "")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)

                if let pronunciation = entry.pronunciation, !pronunciation.isEmpty {
                    Text(pronunciation)
                        .font(.caption)
                        .foregroundColor(.appAccentCyan)
                }
            }

            Spacer()

            // Meaning
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.meaning ?? "")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.trailing)

                // Audio indicator
                if entry.audioFileName != nil {
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundColor(.appAccentPink)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "book.closed" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.appTextTertiary)

            Text(searchText.isEmpty ? "No words yet" : "No matching words")
                .font(.title3.bold())
                .foregroundColor(.appTextSecondary)

            Text(searchText.isEmpty ?
                "Tap the + button to add your first word" :
                "Try a different search term"
            )
            .font(.subheadline)
            .foregroundColor(.appTextTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews
#Preview {
    NavigationStack {
        VocabularyListView(language: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Language }) as! Language)
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
