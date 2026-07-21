import Combine
import Foundation

/// Drives the practice session: a state machine over the phases of a round plus
/// the stopwatch, the forced wait between words (practice only), the fastest-word
/// record, and sprint progress.
@MainActor
final class QuizViewModel: ObservableObject {

    enum Phase: Equatable {
        /// The menu where a mode is chosen.
        case menu
        /// The forced wait before the next word appears (practice only).
        case waiting
        /// A word is shown; the stopwatch ticks up while recalling it.
        case question
        /// The translation and grading buttons are shown; the stopwatch is frozen.
        case answer
        /// A finished sprint's results.
        case results
    }

    @Published private(set) var phase: Phase = .menu
    @Published private(set) var mode: GameMode = .practice(waitsEnabled: true)
    @Published private(set) var round: Round?
    /// Elapsed recall time shown by the stopwatch during `.question` / `.answer`.
    @Published private(set) var elapsed: TimeInterval = 0
    /// Seconds still remaining in the current forced wait during `.waiting`.
    @Published private(set) var waitRemaining: TimeInterval = 0
    /// The fastest single-word recall so far, shown as a target to beat.
    @Published private(set) var fastestWordTime: TimeInterval?
    /// The result of the most recently finished sprint.
    @Published private(set) var lastResult: SprintResult?
    /// Increments each time a forced wait elapses, so the view can beep and vibrate.
    @Published private(set) var waitEndedSignal = 0
    /// Whether spoken answers are being listened for (authorized and available).
    @Published private(set) var speechEnabled = false
    /// The latest transcript of what the user is saying, during `.question`.
    @Published private(set) var transcript = ""
    /// The auto-graded outcome shown during `.answer`, or `nil` in manual mode.
    @Published private(set) var spokenResult: Bool?

    private var answeredCount = 0
    private var correctCount = 0
    private var sprintElapsed: TimeInterval = 0

    /// The wait time carried between rounds. Starts at zero so the first word is immediate.
    private(set) var waitTime: TimeInterval = 0

    private var questionStart: Date?
    private var answerTime: TimeInterval = 0
    private var waitEnd: Date?
    private var sprintStart: Date?
    private var answerShownAt: Date?

    private let words: [Word]
    private let now: () -> Date
    private let tickInterval: TimeInterval
    private let autoAdvanceDelay: TimeInterval
    private let bestTimes: BestTimeStore
    private let speech: SpeechRecognizing
    private var timerCancellable: AnyCancellable?

    init(
        words: [Word] = WordBank.all,
        tickInterval: TimeInterval = 1.0 / 30.0,
        autoAdvanceDelay: TimeInterval = 1.8,
        now: @escaping () -> Date = Date.init,
        bestTimes: BestTimeStore = UserDefaultsBestTimeStore(),
        speech: SpeechRecognizing = SpeechRecognizer()
    ) {
        self.words = words
        self.tickInterval = tickInterval
        self.autoAdvanceDelay = autoAdvanceDelay
        self.now = now
        self.bestTimes = bestTimes
        self.speech = speech
        self.fastestWordTime = bestTimes.fastestWordTime
    }

    /// Resolves microphone/speech permission once, before playing. Safe to call
    /// repeatedly; it only prompts the first time.
    func prepare() async {
        let granted = await speech.requestAuthorization()
        speechEnabled = granted && speech.isAvailable
    }

    /// The header shown while playing.
    var header: SessionHeader {
        SessionHeader(
            elapsed: elapsed,
            fastestWordTime: fastestWordTime,
            sprint: mode.target.map {
                SprintProgress(answered: answeredCount, target: $0, totalElapsed: sprintElapsed)
            }
        )
    }

    /// The best time for a given sprint length, if one has been set.
    func bestSprintTime(target: Int) -> TimeInterval? {
        bestTimes.bestSprintTime(target: target)
    }

    // MARK: - Intents

    func startPractice(waitsEnabled: Bool = true) {
        start(mode: .practice(waitsEnabled: waitsEnabled))
    }

    func startSprint(target: Int, waitsEnabled: Bool = true) {
        start(mode: .sprint(target: max(1, target), waitsEnabled: waitsEnabled))
    }

    /// Reveal the translation manually (used when speech is unavailable). Freezes
    /// the stopwatch and shows the grade buttons.
    func reveal() {
        guard phase == .question, let questionStart else { return }
        answerTime = now().timeIntervalSince(questionStart)
        elapsed = answerTime
        recordWordTime(answerTime)
        spokenResult = nil
        phase = .answer
    }

    /// Give up on the current word: reveal the answer and grade it incorrect.
    func giveUp() {
        autoGrade(correct: false)
    }

    /// Grade a manually revealed word (fallback grade buttons) and move on.
    func grade(correct: Bool) {
        guard phase == .answer, spokenResult == nil else { return }
        commitGrade(correct: correct)
    }

    /// Leave the current session and return to the menu.
    func returnToMenu() {
        speech.stop()
        stopTimer()
        round = nil
        phase = .menu
    }

    /// Replay the just-finished sprint with the same settings.
    func playAgain() {
        start(mode: mode)
    }

    // MARK: - Speech grading

    private func startListening() {
        guard speechEnabled, let language = round?.answerLanguage else { return }
        transcript = ""
        try? speech.start(locale: language.locale) { [weak self] text in
            self?.handleTranscript(text)
        }
    }

    private func handleTranscript(_ text: String) {
        guard phase == .question, let round else { return }
        transcript = text
        if AnswerMatcher.matches(transcript: text, answer: round.answerText) {
            autoGrade(correct: true)
        }
    }

    /// Freeze the stopwatch, show the answer with its outcome, and let the view
    /// auto-advance after a short delay.
    private func autoGrade(correct: Bool) {
        guard phase == .question, let questionStart else { return }
        speech.stop()
        answerTime = now().timeIntervalSince(questionStart)
        elapsed = answerTime
        if correct { recordWordTime(answerTime) }
        spokenResult = correct
        answerShownAt = now()
        phase = .answer
    }

    /// Apply a grade and advance to the wait, next word, or results.
    private func commitGrade(correct: Bool) {
        answeredCount += 1
        if correct { correctCount += 1 }

        // The adaptive wait is always computed; whether it is enforced depends on
        // the mode (practice always, sprint only when waits are enabled).
        let total = WaitTimeCalculator.totalTime(previousWait: waitTime, answerTime: answerTime)
        waitTime = WaitTimeCalculator.nextWaitTime(
            correct: correct,
            currentWait: waitTime,
            totalTime: total
        )

        spokenResult = nil
        answerShownAt = nil

        if let target = mode.target, answeredCount >= target {
            finishSprint(target: target)
        } else {
            beginNextWord()
        }
    }

    // MARK: - Session lifecycle

    private func start(mode: GameMode) {
        self.mode = mode
        waitTime = 0
        answeredCount = 0
        correctCount = 0
        sprintElapsed = 0
        sprintStart = nil
        lastResult = nil
        startTimer()
        beginNextWord()
    }

    private func finishSprint(target: Int) {
        speech.stop()
        let total = sprintStart.map { now().timeIntervalSince($0) } ?? sprintElapsed
        sprintElapsed = total

        let previousBest = bestTimes.bestSprintTime(target: target)
        let isNewBest = previousBest.map { total < $0 } ?? true
        if isNewBest {
            bestTimes.setBestSprintTime(total, target: target)
        }

        lastResult = SprintResult(
            target: target,
            totalTime: total,
            correctCount: correctCount,
            previousBest: previousBest,
            isNewBest: isNewBest
        )
        stopTimer()
        phase = .results
    }

    private func recordWordTime(_ time: TimeInterval) {
        guard fastestWordTime.map({ time < $0 }) ?? true else { return }
        fastestWordTime = time
        bestTimes.fastestWordTime = time
    }

    // MARK: - Phase transitions

    private func beginNextWord() {
        round = Round.random(from: words)
        if mode.usesWaits, waitTime > 0 {
            enterWaiting()
        } else {
            enterQuestion()
        }
    }

    private func enterWaiting() {
        waitEnd = now().addingTimeInterval(waitTime)
        waitRemaining = waitTime
        phase = .waiting
    }

    private func enterQuestion() {
        let start = now()
        questionStart = start
        if mode.isSprint, sprintStart == nil {
            sprintStart = start
        }
        answerTime = 0
        elapsed = 0
        transcript = ""
        spokenResult = nil
        phase = .question
        startListening()
    }

    // MARK: - Timer

    private func startTimer() {
        guard timerCancellable == nil else { return }
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
        if mode.isSprint, let sprintStart, phase != .results {
            sprintElapsed = now().timeIntervalSince(sprintStart)
        }

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
                    waitEndedSignal += 1
                    enterQuestion()
                } else {
                    waitRemaining = remaining
                }
            }
        case .answer:
            // After a spoken answer, show the result briefly then advance.
            if let result = spokenResult, let answerShownAt,
               now().timeIntervalSince(answerShownAt) >= autoAdvanceDelay {
                commitGrade(correct: result)
            }
        case .menu, .results:
            break
        }
    }
}
