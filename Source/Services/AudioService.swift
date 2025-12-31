//
//  AudioService.swift
//  Leevda
//
//  Service for audio recording and playback using AVFoundation
//

import AVFoundation
import Foundation

class AudioService: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = AudioService()

    // MARK: - Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var currentRecordingURL: URL?
    private var currentEntryID: UUID?

    // MARK: - Audio Session Setup
    private override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    // MARK: - Permissions
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }

    // MARK: - Recording
    func startRecording(for entryID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        // Stop any existing recording or playback
        stopRecording { _ in }
        stopPlayback()

        currentEntryID = entryID

        // Generate file name and URL
        let fileName = FileStorageService.shared.generateAudioFileName(for: entryID)
        let fileURL = FileStorageService.shared.getAudioFileURL(for: fileName)
        currentRecordingURL = fileURL

        // Recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    func stopRecording(completion: @escaping (Result<String, Error>) -> Void) {
        guard let recorder = audioRecorder, recorder.isRecording else {
            completion(.failure(AudioError.notRecording))
            return
        }

        recorder.stop()

        guard let entryID = currentEntryID else {
            completion(.failure(AudioError.missingEntryID))
            return
        }

        let fileName = FileStorageService.shared.generateAudioFileName(for: entryID)
        completion(.success(fileName))

        audioRecorder = nil
        currentEntryID = nil
    }

    // MARK: - Playback
    func playAudio(fileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let fileURL = FileStorageService.shared.getAudioFileURL(for: fileName)

        guard FileStorageService.shared.audioFileExists(fileName: fileName) else {
            completion(.failure(AudioError.fileNotFound))
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - State
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }

    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Recording encode error: \(error)")
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            print("Playback finished unsuccessfully")
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Playback decode error: \(error)")
        }
    }
}

// MARK: - Audio Errors
enum AudioError: LocalizedError {
    case notRecording
    case missingEntryID
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .notRecording:
            return "No active recording"
        case .missingEntryID:
            return "Missing entry ID for recording"
        case .fileNotFound:
            return "Audio file not found"
        }
    }
}
