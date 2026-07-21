import SwiftUI

/// The recall phase: a single word shown large, with a hint to tap to reveal.
/// Tapping anywhere reveals the translation.
struct QuestionView: View {
    let round: Round
    let elapsed: TimeInterval
    let onReveal: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            StopwatchLabel(elapsed: elapsed)
                .padding(.top, 8)

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
