import SwiftUI

/// The grading phase. When a spoken answer was graded automatically, it shows the
/// outcome and what was heard; otherwise it shows the manual grade buttons.
struct AnswerView: View {
    let round: Round
    let header: SessionHeader
    /// The auto-graded outcome, or `nil` for manual grading.
    let result: Bool?
    let transcript: String
    let onGrade: (Bool) -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            SessionHeaderView(header: header, onExit: onExit)
                .padding(.top, 8)

            Spacer()

            VStack(spacing: 16) {
                PromptText(text: round.promptText, emphasised: false)
                Divider().frame(maxWidth: 120)
                PromptText(text: round.answerText)
            }

            Spacer()

            footer
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var footer: some View {
        if let result {
            resultBanner(correct: result)
        } else {
            GradeButtons(onGrade: onGrade)
        }
    }

    private func resultBanner(correct: Bool) -> some View {
        VStack(spacing: 8) {
            Label(
                correct ? "¡Correcto!" : "Not quite",
                systemImage: correct ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.title.weight(.bold))
            .foregroundStyle(correct ? Color.green : Color.red)

            if !correct, !transcript.isEmpty {
                Text("You said “\(transcript)”")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }
}
