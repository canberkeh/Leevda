//
//  PersistenceController.swift
//  Leevda
//
//  Core Data stack and persistence management
//

import CoreData

struct PersistenceController {
    // MARK: - Singleton
    static let shared = PersistenceController()

    // MARK: - Preview Support
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create sample data for previews
        let english = Language(context: viewContext)
        english.id = UUID()
        english.name = "English"
        english.sortOrder = 0
        english.createdAt = Date()

        let turkish = Language(context: viewContext)
        turkish.id = UUID()
        turkish.name = "Turkish"
        turkish.sortOrder = 1
        turkish.createdAt = Date()

        // Add sample vocabulary
        let entry1 = VocabularyEntry(context: viewContext)
        entry1.id = UUID()
        entry1.word = "hello"
        entry1.meaning = "merhaba"
        entry1.pronunciation = "hə-ˈlō"
        entry1.note = "A greeting used when meeting someone"
        entry1.createdAt = Date()
        entry1.updatedAt = Date()
        entry1.language = english

        let entry2 = VocabularyEntry(context: viewContext)
        entry2.id = UUID()
        entry2.word = "world"
        entry2.meaning = "dünya"
        entry2.pronunciation = "wərld"
        entry2.createdAt = Date()
        entry2.updatedAt = Date()
        entry2.language = english

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved preview error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    // MARK: - Core Data Container
    let container: NSPersistentContainer

    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Leevda")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Default Data Seeding
    func ensureDefaultLanguage() {
        let context = container.viewContext
        let request = Language.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "English")
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)
            if results.isEmpty {
                let english = Language(context: context)
                english.id = UUID()
                english.name = "English"
                english.sortOrder = 0
                english.createdAt = Date()

                try context.save()
                print("✓ Default English language created")
            }
        } catch {
            print("Error ensuring default language: \(error)")
        }
    }

    // MARK: - Save Context
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
