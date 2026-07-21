import Combine
import Foundation

/// Drives the practice session: a state machine over the phases of a round plus
/// the stopwatch and the forced wait between words.
@MainActor
final class QuizViewModel: ObservableObject {

    enum Phase: Equatable {
        /// Before the session has started.
        case idle
        /// The forced wait before the next word appears.
        case waiting
        /// A word is shown; the stopwatch ticks up while recalling it.
        case question
        /// The translation and grading buttons are shown; the stopwatch is frozen.
        case answer
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var round: Round?
    /// Elapsed recall time shown by the stopwatch during `.question` / `.answer`.
    @Published private(set) var elapsed: TimeInterval = 0
    /// Seconds still remaining in the current forced wait during `.waiting`.
    @Published private(set) var waitRemaining: TimeInterval = 0

    /// The wait time carried between rounds. Starts at zero so the first word is immediate.
    private(set) var waitTime: TimeInterval = 0

    private var questionStart: Date?
    private var answerTime: TimeInterval = 0
    private var waitEnd: Date?

    private let words: [Word]
    private let now: () -> Date
    private let tickInterval: TimeInterval
    private var timerCancellable: AnyCancellable?

    init(
        words: [Word] = WordBank.all,
        tickInterval: TimeInterval = 1.0 / 30.0,
        now: @escaping () -> Date = Date.init
    ) {
        self.words = words
        self.tickInterval = tickInterval
        self.now = now
    }

    // MARK: - Intents

    /// Begin a session from idle.
    func start() {
        waitTime = 0
        beginNextWord()
    }

    /// Reveal the translation. Freezes the stopwatch at the recall time.
    func reveal() {
        guard phase == .question, let questionStart else { return }
        answerTime = now().timeIntervalSince(questionStart)
        elapsed = answerTime
        stopTimer()
        phase = .answer
    }

    /// Grade the just-revealed word, update the wait time, and move on.
    func grade(correct: Bool) {
        guard phase == .answer else { return }
        let total = WaitTimeCalculator.totalTime(previousWait: waitTime, answerTime: answerTime)
        waitTime = WaitTimeCalculator.nextWaitTime(
            correct: correct,
            currentWait: waitTime,
            totalTime: total
        )
        beginNextWord()
    }

    // MARK: - Phase transitions

    private func beginNextWord() {
        round = Round.random(from: words)
        if waitTime > 0 {
            enterWaiting()
        } else {
            enterQuestion()
        }
    }

    private func enterWaiting() {
        waitEnd = now().addingTimeInterval(waitTime)
        waitRemaining = waitTime
        phase = .waiting
        startTimer()
    }

    private func enterQuestion() {
        questionStart = now()
        answerTime = 0
        elapsed = 0
        phase = .question
        startTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        timerCancellable = Timer
            .publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimer() {
        timerCancellable = nil
    }

    private func tick() {
        switch phase {
        case .question:
            if let questionStart {
                elapsed = now().timeIntervalSince(questionStart)
            }
        case .waiting:
            if let waitEnd {
                let remaining = waitEnd.timeIntervalSince(now())
                if remaining <= 0 {
                    waitRemaining = 0
                    enterQuestion()
                } else {
                    waitRemaining = remaining
                }
            }
        case .idle, .answer:
            stopTimer()
        }
    }
}
