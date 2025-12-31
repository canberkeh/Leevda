//
//  AudioRecorderView.swift
//  Leevda
//
//  UI component for recording and playing back audio pronunciations
//

import SwiftUI

struct AudioRecorderView: View {
    @ObservedObject var viewModel: AudioRecorderViewModel
    let entryID: UUID

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text("Audio Pronunciation (optional)")
                    .font(.caption.bold())
                    .foregroundColor(.appTextSecondary)

                Spacer()

                if viewModel.hasRecording {
                    Button {
                        viewModel.deleteRecording()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            // Recording/Playback Controls
            VStack(spacing: 16) {
                if viewModel.hasRecording {
                    // Playback View
                    AudioPlayerView(
                        viewModel: viewModel,
                        onReRecord: {
                            viewModel.deleteRecording()
                        }
                    )
                } else {
                    // Recording View
                    RecordingControlView(
                        viewModel: viewModel,
                        entryID: entryID
                    )
                }
            }
            .padding()
            .background(AppTheme.secondaryBackground)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .alert("Microphone Permission Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please allow microphone access in Settings to record audio pronunciations.")
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
    }
}

// MARK: - Recording Control View
struct RecordingControlView: View {
    @ObservedObject var viewModel: AudioRecorderViewModel
    let entryID: UUID

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isRecording {
                // Recording in progress
                VStack(spacing: 12) {
                    // Animated recording indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .opacity(0.8)
                            .overlay(
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(viewModel.isRecording ? 1.5 : 1.0)
                                    .opacity(viewModel.isRecording ? 0 : 0.8)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: viewModel.isRecording)
                            )

                        Text("Recording...")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }

                    // Stop button
                    Button {
                        viewModel.stopRecording()
                    } label: {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                                .font(.title3)
                            Text("Stop Recording")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                }
            } else {
                // Ready to record
                Button {
                    viewModel.startRecording(for: entryID)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.circle.fill")
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Record Pronunciation")
                                .font(.headline)
                            Text("Tap to start recording")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .foregroundColor(.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.tertiaryBackground)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }
            }
        }
    }
}

// MARK: - Previews
#Preview {
    VStack {
        AudioRecorderView(
            viewModel: AudioRecorderViewModel(),
            entryID: UUID()
        )
    }
    .padding()
    .background(Color.appBackground)
}
