import SwiftUI

/// The recall phase. With speech enabled, the app listens for the spoken answer
/// and shows a live transcript; otherwise the user taps to reveal and self-grade.
struct QuestionView: View {
    let round: Round
    let header: SessionHeader
    let speechEnabled: Bool
    let transcript: String
    let onReveal: () -> Void
    let onGiveUp: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            SessionHeaderView(header: header, onExit: onExit)
                .padding(.top, 8)

            if speechEnabled {
                listeningContent
            } else {
                tapToRevealContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Speech mode

    private var listeningContent: some View {
        VStack(spacing: 24) {
            Spacer()

            PromptText(text: round.promptText)

            transcriptView

            Spacer()

            VStack(spacing: 16) {
                Label("Listening…", systemImage: "waveform")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .symbolEffect(.variableColor.iterative, options: .repeating)

                Button(action: onGiveUp) {
                    Text("I don't know")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var transcriptView: some View {
        if transcript.isEmpty {
            Text("Say it in \(round.answerLanguage.displayName)")
                .font(.title3)
                .foregroundStyle(.tertiary)
        } else {
            Text("“\(transcript)”")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .transition(.opacity)
        }
    }

    // MARK: - Fallback (no speech permission)

    private var tapToRevealContent: some View {
        VStack(spacing: 24) {
            Spacer()

            PromptText(text: round.promptText)

            Spacer()

            Text("Tap anywhere to reveal")
                .font(.headline)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onReveal)
    }
}
