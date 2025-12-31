//
//  FileStorageService.swift
//  Leevda
//
//  Service for managing audio file storage in the file system
//

import Foundation

class FileStorageService {
    // MARK: - Singleton
    static let shared = FileStorageService()

    // MARK: - Private Initialization
    private init() {
        createAudioDirectoryIfNeeded()
    }

    // MARK: - Audio Directory
    private var audioDirectoryURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("AudioRecordings", isDirectory: true)
    }

    private func createAudioDirectoryIfNeeded() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: audioDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: audioDirectoryURL, withIntermediateDirectories: true)
                print("✓ Audio directory created at: \(audioDirectoryURL.path)")
            } catch {
                print("Error creating audio directory: \(error)")
            }
        }
    }

    // MARK: - File Operations
    func getAudioFileURL(for fileName: String) -> URL {
        return audioDirectoryURL.appendingPathComponent(fileName)
    }

    func audioFileExists(fileName: String) -> Bool {
        let fileURL = getAudioFileURL(for: fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func deleteAudioFile(fileName: String) {
        let fileURL = getAudioFileURL(for: fileName)

        do {
            try FileManager.default.removeItem(at: fileURL)
            print("✓ Deleted audio file: \(fileName)")
        } catch {
            print("Error deleting audio file \(fileName): \(error)")
        }
    }

    func generateAudioFileName(for entryID: UUID) -> String {
        return "\(entryID.uuidString).m4a"
    }

    // MARK: - Cleanup
    func deleteAllAudioFiles() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: audioDirectoryURL,
                includingPropertiesForKeys: nil
            )

            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            print("✓ Deleted all audio files")
        } catch {
            print("Error deleting all audio files: \(error)")
        }
    }

    func listAudioFiles() -> [String] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: audioDirectoryURL,
                includingPropertiesForKeys: nil
            )
            return fileURLs.map { $0.lastPathComponent }
        } catch {
            print("Error listing audio files: \(error)")
            return []
        }
    }
}
