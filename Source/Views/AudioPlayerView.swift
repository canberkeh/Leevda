//
//  AudioPlayerView.swift
//  Leevda
//
//  UI component for playing back recorded audio pronunciations
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var viewModel: AudioRecorderViewModel
    let onReRecord: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Success indicator
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Audio Recorded")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)

                    Text("Tap to play or re-record")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()
            }

            // Playback Controls
            HStack(spacing: 16) {
                // Play/Stop Button
                Button {
                    if viewModel.isPlaying {
                        viewModel.stopPlayback()
                    } else {
                        viewModel.playRecording()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)

                        Text(viewModel.isPlaying ? "Stop" : "Play")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        viewModel.isPlaying ?
                            AnyShapeStyle(Color.orange) :
                            AnyShapeStyle(AppTheme.primaryGradient)
                    )
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }

                // Re-record Button
                Button {
                    viewModel.stopPlayback()
                    onReRecord()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.title3)

                        Text("Re-record")
                            .font(.subheadline)
                    }
                    .foregroundColor(.appAccentPurple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
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
        AudioPlayerView(
            viewModel: {
                let vm = AudioRecorderViewModel()
                vm.hasRecording = true
                return vm
            }(),
            onReRecord: {}
        )
    }
    .padding()
    .background(Color.appBackground)
}
