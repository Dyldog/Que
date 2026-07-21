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

    private let correctColor = ArcadePalette.neon
    private let wrongColor = Color(red: 1.0, green: 0.32, blue: 0.4)

    var body: some View {
        VStack(spacing: 24) {
            SessionHeaderView(header: header, onExit: onExit)
                .padding(.top, 8)

            Spacer()

            VStack(spacing: 16) {
                PromptText(text: round.promptText, emphasised: false)
                Rectangle()
                    .fill(ArcadePalette.neon.opacity(0.4))
                    .frame(width: 120, height: 2)
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
        let color = correct ? correctColor : wrongColor
        return VStack(spacing: 8) {
            Label(
                correct ? "¡CORRECTO!" : "NOPE",
                systemImage: correct ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.system(size: 30, weight: .black, design: .monospaced))
            .foregroundStyle(color)
            .neonGlow(color, radius: 12)

            if !correct, !transcript.isEmpty {
                Text("YOU SAID “\(transcript.uppercased())”")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
    }
}
