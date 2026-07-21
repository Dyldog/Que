import Foundation
import Testing
@testable import Que

/// A controllable clock so time-based logic can be tested deterministically.
private final class TestClock {
    var now = Date(timeIntervalSince1970: 0)
    func advance(_ seconds: TimeInterval) {
        now = now.addingTimeInterval(seconds)
    }
}

@MainActor
struct QuizViewModelTests {

    private func fixedList() -> WordList {
        WordList(
            id: "test.fixed",
            name: "Test",
            kind: .custom,
            front: .spanish,
            back: .english,
            words: [Word(front: "Qué", back: "What?")]
        )
    }

    private func makeViewModel(
        clock: TestClock,
        bestTimes: BestTimeStore = InMemoryBestTimeStore(),
        leaderboard: LeaderboardStore = InMemoryLeaderboardStore(),
        wordLists: WordListStore = InMemoryWordListStore(),
        generator: WordListGenerating = FakeWordListGenerator(),
        list: WordList? = nil
    ) -> QuizViewModel {
        let viewModel = QuizViewModel(
            tickInterval: 60,
            now: { clock.now },
            bestTimes: bestTimes,
            leaderboard: leaderboard,
            wordLists: wordLists,
            generator: generator,
            speech: FakeSpeechRecognizer()
        )
        viewModel.selectList(list ?? fixedList())
        return viewModel
    }

    private func makeViewModel(clock: TestClock, speech: SpeechRecognizing) -> QuizViewModel {
        let viewModel = QuizViewModel(
            tickInterval: 60,
            now: { clock.now },
            bestTimes: InMemoryBestTimeStore(),
            leaderboard: InMemoryLeaderboardStore(),
            wordLists: InMemoryWordListStore(),
            generator: FakeWordListGenerator(),
            speech: speech
        )
        viewModel.selectList(fixedList())
        return viewModel
    }

    private func answer(_ viewModel: QuizViewModel, clock: TestClock, recall: TimeInterval, correct: Bool) {
        clock.advance(recall)
        viewModel.reveal()
        viewModel.grade(correct: correct)
    }

    // MARK: - Fastest word

    @Test
    func fastestWordTimeTracksTheQuickestRecall() {
        let clock = TestClock()
        let store = InMemoryBestTimeStore()
        let viewModel = makeViewModel(clock: clock, bestTimes: store)

        viewModel.startSprint(target: 3, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 5, correct: true)
        #expect(viewModel.fastestWordTime == 5)

        answer(viewModel, clock: clock, recall: 2, correct: true)
        #expect(viewModel.fastestWordTime == 2)

        answer(viewModel, clock: clock, recall: 8, correct: true)
        #expect(viewModel.fastestWordTime == 2)
        #expect(store.fastestWordTime == 2)
    }

    // MARK: - Sprint completion + leaderboard

    @Test
    func flawlessSprintFinishesIntoNameEntryThenRecordsScorePerList() {
        let clock = TestClock()
        let leaderboard = InMemoryLeaderboardStore()
        let viewModel = makeViewModel(clock: clock, leaderboard: leaderboard)

        viewModel.startSprint(target: 3, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 2, correct: true)
        answer(viewModel, clock: clock, recall: 3, correct: true)
        #expect(viewModel.phase == .question)
        answer(viewModel, clock: clock, recall: 4, correct: true)

        #expect(viewModel.phase == .nameEntry)
        let result = try! #require(viewModel.lastResult)
        #expect(result.config == SprintConfig(listID: "test.fixed", target: 3, waitsEnabled: false))
        #expect(result.title == "Test")
        #expect(result.totalTime == 9)
        #expect(result.correctCount == 3)

        viewModel.submitInitials("dje")
        #expect(viewModel.phase == .results)
        #expect(viewModel.placement == 0)

        let entries = leaderboard.entries(for: result.config)
        #expect(entries.count == 1)
        #expect(entries[0].initials == "DJE")
        #expect(entries[0].time == 9)

        // The board is titled by the list and separated by its id.
        let board = try! #require(leaderboard.boards().first)
        #expect(board.title == "Test")
        #expect(board.config.listID == "test.fixed")
    }

    @Test
    func missingAnyAnswerSkipsNameEntryAndRecordsNothing() {
        let clock = TestClock()
        let leaderboard = InMemoryLeaderboardStore()
        let viewModel = makeViewModel(clock: clock, leaderboard: leaderboard)

        viewModel.startSprint(target: 3, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 2, correct: true)
        answer(viewModel, clock: clock, recall: 3, correct: false)
        answer(viewModel, clock: clock, recall: 4, correct: true)

        // One wrong answer means no leaderboard eligibility: straight to results.
        #expect(viewModel.phase == .results)
        let result = try! #require(viewModel.lastResult)
        #expect(result.correctCount == 2)
        #expect(viewModel.placement == nil)
        #expect(viewModel.lastEntryID == nil)
        #expect(leaderboard.boards().isEmpty)
    }

    @Test
    func differentListsGetDifferentBoards() {
        let clock = TestClock()
        let leaderboard = InMemoryLeaderboardStore()
        let listA = fixedList()
        let listB = WordList(id: "test.b", name: "Other", kind: .custom, front: .spanish, back: .english, words: [Word(front: "Sí", back: "Yes")])

        let viewModel = makeViewModel(clock: clock, leaderboard: leaderboard, list: listA)
        viewModel.startSprint(target: 1, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 3, correct: true)
        viewModel.submitInitials("AAA")

        viewModel.selectList(listB)
        viewModel.startSprint(target: 1, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 4, correct: true)
        viewModel.submitInitials("BBB")

        #expect(leaderboard.boards().count == 2)
        #expect(leaderboard.entries(for: SprintConfig(listID: "test.fixed", target: 1, waitsEnabled: false)).count == 1)
        #expect(leaderboard.entries(for: SprintConfig(listID: "test.b", target: 1, waitsEnabled: false)).count == 1)
    }

    // MARK: - Waits

    @Test
    func sprintWithWaitsEnforcesTheWaitBetweenWords() {
        let clock = TestClock()
        let viewModel = makeViewModel(clock: clock)

        viewModel.startSprint(target: 3, waitsEnabled: true)
        #expect(viewModel.phase == .question)

        clock.advance(4)
        viewModel.reveal()
        viewModel.grade(correct: true)
        #expect(viewModel.phase == .waiting)
        #expect(viewModel.waitTime == 2)
    }

    // MARK: - Lists

    @Test
    func savingAndDeletingUserLists() {
        let clock = TestClock()
        let store = InMemoryWordListStore()
        let viewModel = makeViewModel(clock: clock, wordLists: store)

        let list = WordList(id: "mine", name: "Mine", kind: .custom, front: .french, back: .english, words: [Word(front: "chat", back: "cat")])
        viewModel.saveList(list)
        #expect(viewModel.userLists.contains { $0.id == "mine" })
        #expect(viewModel.selectedList.id == "mine")

        viewModel.deleteList(list)
        #expect(!viewModel.userLists.contains { $0.id == "mine" })
    }

    // MARK: - Generation

    @Test
    func generatedListProducesWordsAtStart() async {
        let clock = TestClock()
        let generator = FakeWordListGenerator(result: [
            Word(front: "un", back: "one"),
            Word(front: "deux", back: "two"),
        ])
        let promptList = WordList(id: "gen.fr", name: "French Numbers", kind: .prompt, front: .french, back: .english, prompt: "french numbers")
        let viewModel = makeViewModel(clock: clock, generator: generator, list: promptList)

        viewModel.startSprint(target: 2, waitsEnabled: false)
        #expect(viewModel.phase == .generating)

        await viewModel.awaitGeneration()
        #expect(viewModel.phase == .question)
        #expect(viewModel.round != nil)
    }

    @Test
    func generationFailureReturnsToMenuWithError() async {
        let clock = TestClock()
        let generator = FakeWordListGenerator(isAvailable: false, error: WordListGenerationError.unavailable)
        let promptList = WordList(id: "gen.x", name: "Nope", kind: .prompt, front: .french, back: .english, prompt: "x")
        let viewModel = makeViewModel(clock: clock, generator: generator, list: promptList)

        viewModel.startSprint(target: 2, waitsEnabled: false)
        await viewModel.awaitGeneration()

        #expect(viewModel.phase == .menu)
        #expect(viewModel.generationError != nil)
    }

    // MARK: - Speech grading

    @Test
    func hearingTheCorrectAnswerAutoGradesItCorrect() async {
        let clock = TestClock()
        let speech = FakeSpeechRecognizer()
        let viewModel = makeViewModel(clock: clock, speech: speech)
        await viewModel.prepare()

        viewModel.startSprint(target: 3, waitsEnabled: false)
        #expect(viewModel.phase == .question)
        #expect(speech.isListening)

        let expected = try! #require(viewModel.round?.answerText)
        clock.advance(2)
        speech.hear(expected)

        #expect(viewModel.phase == .answer)
        #expect(viewModel.spokenResult == true)
        #expect(!speech.isListening)
        #expect(viewModel.fastestWordTime == 2)
    }

    @Test
    func givingUpAutoGradesIncorrect() async {
        let clock = TestClock()
        let speech = FakeSpeechRecognizer()
        let viewModel = makeViewModel(clock: clock, speech: speech)
        await viewModel.prepare()

        viewModel.startSprint(target: 3, waitsEnabled: false)
        clock.advance(3)
        viewModel.giveUp()

        #expect(viewModel.phase == .answer)
        #expect(viewModel.spokenResult == false)
        #expect(!speech.isListening)
    }
}
