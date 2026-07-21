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

    private let neon = ArcadePalette.neon

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
                Label("LISTENING", systemImage: "waveform")
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundStyle(neon)
                    .tracking(2)
                    .symbolEffect(.variableColor.iterative, options: .repeating)

                Button("I DON'T KNOW", action: onGiveUp)
                    .buttonStyle(.neon(ArcadePalette.hot, filled: false))
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var transcriptView: some View {
        if transcript.isEmpty {
            Text("SAY IT IN \(round.answerLanguage.displayName.uppercased())")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
        } else {
            Text("“\(transcript)”")
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(neon)
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

            Text("TAP TO REVEAL")
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(2)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onReveal)
    }
}
