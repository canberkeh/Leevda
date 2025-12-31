//
//  LeevdaApp.swift
//  Leevda
//
//  Main app entry point with Core Data and theme configuration
//

import SwiftUI
import AVFoundation

@main
struct LeevdaApp: App {
    // Core Data persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        // Ensure default English language exists
        persistenceController.ensureDefaultLanguage()

        // Configure audio session
        configureAudioSession()

        // Apply dark theme globally
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            LanguageSelectionView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.dark) // Force dark theme
                .accentColor(AppTheme.accentPurple) // Set accent color
        }
    }

    // MARK: - Configuration
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            print("✓ Audio session configured")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func configureAppearance() {
        // Configure navigation bar appearance for dark theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Configure toolbar appearance
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = UIColor(AppTheme.background)

        UIToolbar.appearance().standardAppearance = toolbarAppearance
        UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance

        print("✓ Dark theme configured")
    }
}
