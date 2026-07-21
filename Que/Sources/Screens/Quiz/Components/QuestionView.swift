import SwiftUI

/// The recall phase: a single word shown large, with a hint to tap to reveal.
/// Tapping the word area reveals the translation.
struct QuestionView: View {
    let round: Round
    let header: SessionHeader
    let onReveal: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            SessionHeaderView(header: header, onExit: onExit)
                .padding(.top, 8)

            revealArea
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var revealArea: some View {
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
