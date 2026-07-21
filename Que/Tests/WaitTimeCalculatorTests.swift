import Testing
@testable import Que

struct WaitTimeCalculatorTests {

    @Test
    func totalTimeIsWaitPlusAnswer() {
        let total = WaitTimeCalculator.totalTime(previousWait: 3, answerTime: 2)
        #expect(total == 5)
    }

    @Test
    func correctHalvesTheTotalTime() {
        let next = WaitTimeCalculator.nextWaitTime(correct: true, currentWait: 8, totalTime: 10)
        #expect(next == 5)
    }

    @Test
    func incorrectDoublesTheTotalTime() {
        let next = WaitTimeCalculator.nextWaitTime(correct: false, currentWait: 3, totalTime: 10)
        #expect(next == 20)
    }

    @Test
    func incorrectUsesDoubleTheCurrentWaitWhenBigger() {
        // totalTime * 2 = 8, currentWait * 2 = 12 -> the larger wins.
        let next = WaitTimeCalculator.nextWaitTime(correct: false, currentWait: 6, totalTime: 4)
        #expect(next == 12)
    }

    @Test
    func firstRoundStartsWithNoWait() {
        // With no previous wait, total time is just the answer time...
        let total = WaitTimeCalculator.totalTime(previousWait: 0, answerTime: 4)
        #expect(total == 4)
        // ...and a correct answer halves it.
        let next = WaitTimeCalculator.nextWaitTime(correct: true, currentWait: 0, totalTime: total)
        #expect(next == 2)
    }
}
