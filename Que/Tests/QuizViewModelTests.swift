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

    private func makeViewModel(
        clock: TestClock,
        bestTimes: BestTimeStore = InMemoryBestTimeStore(),
        leaderboard: LeaderboardStore = InMemoryLeaderboardStore(),
        speech: SpeechRecognizing = FakeSpeechRecognizer()
    ) -> QuizViewModel {
        QuizViewModel(
            words: [Word(id: 0, spanish: "Qué", english: "What?")],
            tickInterval: 60, // effectively no timer ticks during tests
            now: { clock.now },
            bestTimes: bestTimes,
            leaderboard: leaderboard,
            speech: speech
        )
    }

    /// Answer a question that takes `recall` seconds, via the manual path.
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
        #expect(viewModel.fastestWordTime == 2) // slower recall doesn't lower the record
        #expect(store.fastestWordTime == 2)     // and it is persisted
    }

    @Test
    func fastestWordTimeSeedsFromTheStore() {
        let clock = TestClock()
        let viewModel = makeViewModel(clock: clock, bestTimes: InMemoryBestTimeStore(fastestWordTime: 3))
        #expect(viewModel.fastestWordTime == 3)

        viewModel.startSprint(target: 1, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 4, correct: true) // slower than the record
        #expect(viewModel.fastestWordTime == 3)
    }

    // MARK: - Sprint completion + leaderboard

    @Test
    func sprintFinishesIntoNameEntryThenRecordsScore() {
        let clock = TestClock()
        let leaderboard = InMemoryLeaderboardStore()
        let viewModel = makeViewModel(clock: clock, leaderboard: leaderboard)

        viewModel.startSprint(target: 3, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 2, correct: true)
        answer(viewModel, clock: clock, recall: 3, correct: false)
        #expect(viewModel.phase == .question) // not finished yet
        answer(viewModel, clock: clock, recall: 4, correct: true)

        // Finishing goes to name entry, not straight to results.
        #expect(viewModel.phase == .nameEntry)
        let result = try! #require(viewModel.lastResult)
        #expect(result.config == SprintConfig(target: 3, waitsEnabled: false))
        #expect(result.totalTime == 9) // 2 + 3 + 4, no waits
        #expect(result.correctCount == 2)

        viewModel.submitInitials("dje")
        #expect(viewModel.phase == .results)
        #expect(viewModel.placement == 0)

        let entries = leaderboard.entries(for: result.config)
        #expect(entries.count == 1)
        #expect(entries[0].initials == "DJE") // normalized to uppercase
        #expect(entries[0].time == 9)
    }

    @Test
    func aSlowerSecondRunPlacesBelowTheFirst() {
        let clock = TestClock()
        let leaderboard = InMemoryLeaderboardStore()
        let viewModel = makeViewModel(clock: clock, leaderboard: leaderboard)

        viewModel.startSprint(target: 1, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 5, correct: true)
        viewModel.submitInitials("AAA")
        #expect(viewModel.placement == 0)

        viewModel.playAgain()
        answer(viewModel, clock: clock, recall: 9, correct: true)
        viewModel.submitInitials("BBB")
        #expect(viewModel.placement == 1) // slower → second place

        let entries = leaderboard.entries(for: SprintConfig(target: 1, waitsEnabled: false))
        #expect(entries.map(\.initials) == ["AAA", "BBB"])
    }

    @Test
    func suggestedInitialsUseTheLastEntry() {
        let clock = TestClock()
        let leaderboard = InMemoryLeaderboardStore()
        let viewModel = makeViewModel(clock: clock, leaderboard: leaderboard)
        #expect(viewModel.suggestedInitials == "AAA")

        viewModel.startSprint(target: 1, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 5, correct: true)
        viewModel.submitInitials("ZZZ")
        #expect(viewModel.suggestedInitials == "ZZZ")
    }

    // MARK: - Waits

    @Test
    func sprintWithWaitsEnforcesTheWaitBetweenWords() {
        let clock = TestClock()
        let viewModel = makeViewModel(clock: clock)

        viewModel.startSprint(target: 3, waitsEnabled: true)
        #expect(viewModel.phase == .question) // first word is immediate

        clock.advance(4)
        viewModel.reveal()
        viewModel.grade(correct: true) // wait becomes 4 / 2 = 2s
        #expect(viewModel.phase == .waiting)
        #expect(viewModel.waitTime == 2)
    }

    @Test
    func sprintWithoutWaitsGoesStraightToTheNextWord() {
        let clock = TestClock()
        let viewModel = makeViewModel(clock: clock)

        viewModel.startSprint(target: 3, waitsEnabled: false)
        clock.advance(4)
        viewModel.reveal()
        viewModel.grade(correct: true)
        #expect(viewModel.phase == .question)
    }

    // MARK: - Speech grading

    @Test
    func prepareEnablesSpeechWhenAuthorized() async {
        let viewModel = makeViewModel(clock: TestClock(), speech: FakeSpeechRecognizer(authorized: true, isAvailable: true))
        await viewModel.prepare()
        #expect(viewModel.speechEnabled)
    }

    @Test
    func prepareLeavesSpeechDisabledWhenDenied() async {
        let viewModel = makeViewModel(clock: TestClock(), speech: FakeSpeechRecognizer(authorized: false))
        await viewModel.prepare()
        #expect(!viewModel.speechEnabled)
    }

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
    func hearingAWrongAnswerKeepsListening() async {
        let clock = TestClock()
        let speech = FakeSpeechRecognizer()
        let viewModel = makeViewModel(clock: clock, speech: speech)
        await viewModel.prepare()

        viewModel.startSprint(target: 3, waitsEnabled: false)
        speech.hear("something unrelated")

        #expect(viewModel.phase == .question)
        #expect(viewModel.spokenResult == nil)
        #expect(speech.isListening)
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
