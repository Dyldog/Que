import SwiftUI

/// The single screen of the app. Renders the current phase of the sprint over the
/// shared pinball backglass.
struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()

    let waitsDisabled: Bool = true
    
    var body: some View {
        ZStack {
            PinballBackground()
            content
                .animation(.easeInOut(duration: 0.2), value: viewModel.phase)
                .padding()
        }
        .tint(ArcadePalette.neon)
        .preferredColorScheme(.dark)
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
                listName: viewModel.selectedList.name,
                generationError: viewModel.generationError,
                onChangeList: viewModel.openListPicker,
                onStartSprint: { viewModel.startSprint(target: $0, waitsEnabled: $1) },
                onOpenLeaderboard: viewModel.openLeaderboard,
                waitDisabled: waitsDisabled
            )

        case .listPicker:
            ListPickerView(
                bundled: viewModel.bundledLists,
                bundledJSON: viewModel.bundledJSONLists,
                userLists: viewModel.userLists,
                selectedID: viewModel.selectedList.id,
                generationAvailable: viewModel.generationAvailable,
                onSelect: viewModel.selectList,
                onPreview: viewModel.previewList,
                onEdit: viewModel.editList,
                onDelete: viewModel.deleteList,
                onCreate: viewModel.createList,
                onBack: viewModel.backToMenu
            )

        case .listPreview:
            if let list = viewModel.selectedList as WordList? {
                ListPreviewView(
                    list: list,
                    onStart: { viewModel.startSprint(target: $0, waitsEnabled: $1) },
                    onBack: { viewModel.openListPicker() }
                )
            }

        case .listEditor:
            if let list = viewModel.editingList {
                ListEditorView(
                    list: list,
                    canDelete: viewModel.userLists.contains { $0.id == list.id },
                    generationAvailable: viewModel.generationAvailable,
                    onSave: viewModel.saveList,
                    onDelete: viewModel.deleteList,
                    onCancel: viewModel.cancelEditing
                )
            }

        case .generating:
            GeneratingView(
                listName: viewModel.selectedList.name,
                onCancel: viewModel.cancelGeneration
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

        case .nameEntry:
            if let result = viewModel.lastResult {
                NameEntryView(
                    time: result.totalTime,
                    title: result.title,
                    config: result.config,
                    initialInitials: viewModel.suggestedInitials,
                    onSubmit: viewModel.submitInitials
                )
            }

        case .results:
            if let result = viewModel.lastResult {
                ResultsView(
                    result: result,
                    placement: viewModel.placement,
                    entries: viewModel.leaderboardEntries(for: result.config),
                    highlightID: viewModel.lastEntryID,
                    onPlayAgain: viewModel.playAgain,
                    onMenu: viewModel.returnToMenu
                )
            }

        case .leaderboard:
            LeaderboardBrowserView(
                boards: viewModel.leaderboardBoards(),
                onBack: viewModel.closeLeaderboard,
                waitsDisabled: waitsDisabled
            )
        }
    }
}

#Preview {
    QuizView()
}
