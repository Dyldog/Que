import SwiftUI

/// The single screen of the app. Renders the current phase of the practice session.
struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()

    var body: some View {
        content
            .animation(.easeInOut(duration: 0.2), value: viewModel.phase)
            .padding()
            // Ask for microphone/speech permission once, up front.
            .task { await viewModel.prepare() }
            // Vibrate when a forced wait ends...
            .sensoryFeedback(.impact(weight: .heavy), trigger: viewModel.waitEndedSignal)
            // ...and beep at the same moment.
            .onChange(of: viewModel.waitEndedSignal) { _, _ in
                WaitEndFeedback.play()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .menu:
            MenuView(
                fastestWordTime: viewModel.fastestWordTime,
                bestSprintTime: viewModel.bestSprintTime(target:),
                onStartPractice: { viewModel.startPractice(waitsEnabled: $0) },
                onStartSprint: { viewModel.startSprint(target: $0, waitsEnabled: $1) }
            )

        case .waiting:
            WaitingView(
                remaining: viewModel.waitRemaining,
                total: viewModel.waitTime,
                onExit: viewModel.returnToMenu
            )

        case .question:
            if let round = viewModel.round {
                QuestionView(
                    round: round,
                    header: viewModel.header,
                    speechEnabled: viewModel.speechEnabled,
                    transcript: viewModel.transcript,
                    onReveal: viewModel.reveal,
                    onGiveUp: viewModel.giveUp,
                    onExit: viewModel.returnToMenu
                )
            }

        case .answer:
            if let round = viewModel.round {
                AnswerView(
                    round: round,
                    header: viewModel.header,
                    result: viewModel.spokenResult,
                    transcript: viewModel.transcript,
                    onGrade: viewModel.grade,
                    onExit: viewModel.returnToMenu
                )
            }

        case .results:
            if let result = viewModel.lastResult {
                ResultsView(
                    result: result,
                    onPlayAgain: viewModel.playAgain,
                    onMenu: viewModel.returnToMenu
                )
            }
        }
    }
}

#Preview {
    QuizView()
}
