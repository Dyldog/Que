import Foundation

/// Pure, testable rules that drive the adaptive spacing between words.
///
/// The "total time" for a round is the wait time that preceded the word plus the
/// amount of time it took to answer once the word appeared. Answering correctly
/// halves the wait; answering incorrectly at least doubles it.
enum WaitTimeCalculator {

    /// The total time for a round: the preceding wait plus the time taken to answer.
    static func totalTime(previousWait: TimeInterval, answerTime: TimeInterval) -> TimeInterval {
        previousWait + answerTime
    }

    /// The next wait time, given whether the answer was correct.
    ///
    /// - Correct: half of the total time.
    /// - Incorrect: double the total time, or double the current wait time,
    ///   whichever is bigger.
    static func nextWaitTime(
        correct: Bool,
        currentWait: TimeInterval,
        totalTime: TimeInterval
    ) -> TimeInterval {
        if correct {
            totalTime / 2
        } else {
            max(totalTime * 2, currentWait * 2)
        }
    }
}
