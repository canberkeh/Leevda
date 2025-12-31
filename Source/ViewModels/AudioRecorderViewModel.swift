//
//  AudioRecorderViewModel.swift
//  Leevda
//
//  ViewModel for managing audio recording and playback state
//

import SwiftUI
import AVFoundation

class AudioRecorderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var hasRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var permissionGranted = false
    @Published var showPermissionAlert = false
    @Published var errorMessage: String?

    // MARK: - Properties
    var audioFileName: String?
    private let audioService: AudioService
    private var entryID: UUID?

    // MARK: - Initialization
    init(audioService: AudioService = AudioService.shared) {
        self.audioService = audioService
        checkPermission()
    }

    // MARK: - Permission
    func checkPermission() {
        audioService.requestPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if !granted {
                    self?.showPermissionAlert = true
                }
            }
        }
    }

    // MARK: - Recording
    func toggleRecording(for entryID: UUID) {
        if isRecording {
            stopRecording()
        } else {
            startRecording(for: entryID)
        }
    }

    func startRecording(for entryID: UUID) {
        guard permissionGranted else {
            checkPermission()
            return
        }

        self.entryID = entryID
        audioService.startRecording(for: entryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isRecording = true
                case .failure(let error):
                    self?.errorMessage = "Recording failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func stopRecording() {
        audioService.stopRecording { [weak self] result in
            DispatchQueue.main.async {
                self?.isRecording = false

                switch result {
                case .success(let fileName):
                    self?.audioFileName = fileName
                    self?.hasRecording = true
                case .failure(let error):
                    self?.errorMessage = "Failed to save recording: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Playback
    func playRecording() {
        guard let fileName = audioFileName else { return }

        audioService.playAudio(fileName: fileName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isPlaying = true
                case .failure(let error):
                    self?.errorMessage = "Playback failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func stopPlayback() {
        audioService.stopPlayback()
        isPlaying = false
    }

    // MARK: - Delete Recording
    func deleteRecording() {
        if let fileName = audioFileName {
            FileStorageService.shared.deleteAudioFile(fileName: fileName)
        }
        audioFileName = nil
        hasRecording = false
    }

    // MARK: - Load Existing Recording
    func loadExistingRecording(fileName: String?) {
        audioFileName = fileName
        hasRecording = fileName != nil
    }

    // MARK: - Helpers
    func clearError() {
        errorMessage = nil
    }
}
