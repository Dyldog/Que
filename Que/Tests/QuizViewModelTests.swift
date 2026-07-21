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
        store: BestTimeStore
    ) -> QuizViewModel {
        QuizViewModel(
            words: [Word(id: 0, spanish: "Qué", english: "What?")],
            tickInterval: 60, // effectively no timer ticks during tests
            now: { clock.now },
            bestTimes: store
        )
    }

    /// Answer a sprint question that takes `recall` seconds to reveal.
    private func answer(_ viewModel: QuizViewModel, clock: TestClock, recall: TimeInterval, correct: Bool) {
        clock.advance(recall)
        viewModel.reveal()
        viewModel.grade(correct: correct)
    }

    @Test
    func fastestWordTimeTracksTheQuickestRecall() {
        let clock = TestClock()
        let store = InMemoryBestTimeStore()
        let viewModel = makeViewModel(clock: clock, store: store)

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
        let store = InMemoryBestTimeStore(fastestWordTime: 3)
        let viewModel = makeViewModel(clock: clock, store: store)

        #expect(viewModel.fastestWordTime == 3)

        viewModel.startSprint(target: 1, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 4, correct: true) // slower than the record
        #expect(viewModel.fastestWordTime == 3)
    }

    @Test
    func sprintFinishesAfterTargetAndRecordsTotalTime() {
        let clock = TestClock()
        let store = InMemoryBestTimeStore()
        let viewModel = makeViewModel(clock: clock, store: store)

        viewModel.startSprint(target: 3, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 2, correct: true)
        answer(viewModel, clock: clock, recall: 3, correct: false)
        #expect(viewModel.phase == .question) // not finished yet
        answer(viewModel, clock: clock, recall: 4, correct: true)

        #expect(viewModel.phase == .results)
        let result = try! #require(viewModel.lastResult)
        #expect(result.target == 3)
        #expect(result.totalTime == 9)      // 2 + 3 + 4, no waits in a sprint
        #expect(result.correctCount == 2)
        #expect(result.isNewBest == true)
        #expect(result.previousBest == nil)
        #expect(store.bestSprintTime(target: 3) == 9)
    }

    @Test
    func sprintReportsNewBestOnlyWhenBeatingThePreviousTime() {
        let clock = TestClock()
        let store = InMemoryBestTimeStore(sprintTimes: [2: 10])
        let viewModel = makeViewModel(clock: clock, store: store)

        // A slower run does not beat the record.
        viewModel.startSprint(target: 2, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 6, correct: true)
        answer(viewModel, clock: clock, recall: 6, correct: true)
        var result = try! #require(viewModel.lastResult)
        #expect(result.totalTime == 12)
        #expect(result.isNewBest == false)
        #expect(result.previousBest == 10)
        #expect(store.bestSprintTime(target: 2) == 10) // unchanged

        // A faster run sets a new record.
        viewModel.startSprint(target: 2, waitsEnabled: false)
        answer(viewModel, clock: clock, recall: 3, correct: true)
        answer(viewModel, clock: clock, recall: 4, correct: true)
        result = try! #require(viewModel.lastResult)
        #expect(result.totalTime == 7)
        #expect(result.isNewBest == true)
        #expect(store.bestSprintTime(target: 2) == 7)
    }

    @Test
    func sprintWithWaitsEnforcesTheWaitBetweenWords() {
        let clock = TestClock()
        let viewModel = makeViewModel(clock: clock, store: InMemoryBestTimeStore())

        viewModel.startSprint(target: 3, waitsEnabled: true)
        // First word is immediate (wait starts at zero).
        #expect(viewModel.phase == .question)

        clock.advance(4)
        viewModel.reveal()
        viewModel.grade(correct: true) // wait becomes 4 / 2 = 2s, so a wait is enforced
        #expect(viewModel.phase == .waiting)
        #expect(viewModel.waitTime == 2)
    }

    @Test
    func sprintWithoutWaitsGoesStraightToTheNextWord() {
        let clock = TestClock()
        let viewModel = makeViewModel(clock: clock, store: InMemoryBestTimeStore())

        viewModel.startSprint(target: 3, waitsEnabled: false)
        clock.advance(4)
        viewModel.reveal()
        viewModel.grade(correct: true)
        #expect(viewModel.phase == .question) // no wait
    }
}
