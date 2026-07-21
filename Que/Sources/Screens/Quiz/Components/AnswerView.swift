import SwiftUI

/// The grading phase: the prompt, its translation, and the large grade buttons.
struct AnswerView: View {
    let round: Round
    let elapsed: TimeInterval
    let onGrade: (Bool) -> Void

    var body: some View {
        VStack(spacing: 24) {
            StopwatchLabel(elapsed: elapsed)
                .padding(.top, 8)

            Spacer()

            VStack(spacing: 16) {
                PromptText(text: round.promptText, emphasised: false)
                Divider().frame(maxWidth: 120)
                PromptText(text: round.answerText)
            }

            Spacer()

            GradeButtons(onGrade: onGrade)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
    }
}
