import SwiftUI

/// The single screen of the app. Renders the current phase of the practice session.
struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()

    var body: some View {
        content
            .animation(.easeInOut(duration: 0.2), value: viewModel.phase)
            .padding()
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .idle:
            StartView(onStart: viewModel.start)

        case .waiting:
            WaitingView(remaining: viewModel.waitRemaining, total: viewModel.waitTime)

        case .question:
            if let round = viewModel.round {
                QuestionView(
                    round: round,
                    elapsed: viewModel.elapsed,
                    onReveal: viewModel.reveal
                )
            }

        case .answer:
            if let round = viewModel.round {
                AnswerView(
                    round: round,
                    elapsed: viewModel.elapsed,
                    onGrade: viewModel.grade
                )
            }
        }
    }
}

#Preview {
    QuizView()
}
