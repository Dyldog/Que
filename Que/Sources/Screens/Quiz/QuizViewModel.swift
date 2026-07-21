import Combine
import Foundation

/// Drives a sprint: a state machine over the phases of a round plus the stopwatch,
/// the optional adaptive wait between words, the fastest-word record, sprint
/// progress, and leaderboard name entry.
@MainActor
final class QuizViewModel: ObservableObject {

    enum Phase: Equatable {
        /// The menu where a sprint is configured.
        case menu
        /// The forced wait before the next word appears (when waits are enabled).
        case waiting
        /// A word is shown; the stopwatch ticks up while recalling it.
        case question
        /// The translation is shown; the stopwatch is frozen.
        case answer
        /// Entering three initials for the leaderboard after a finished sprint.
        case nameEntry
        /// A finished sprint's results and its leaderboard.
        case results
        /// Browsing the leaderboards from the menu.
        case leaderboard
    }

    @Published private(set) var phase: Phase = .menu
    @Published private(set) var config = SprintConfig(target: 10, waitsEnabled: true)
    @Published private(set) var round: Round?
    /// Elapsed recall time shown by the stopwatch during `.question` / `.answer`.
    @Published private(set) var elapsed: TimeInterval = 0
    /// Seconds still remaining in the current forced wait during `.waiting`.
    @Published private(set) var waitRemaining: TimeInterval = 0
    /// The fastest single-word recall so far, shown as a target to beat.
    @Published private(set) var fastestWordTime: TimeInterval?
    /// The result of the most recently finished sprint (awaiting or showing its score).
    @Published private(set) var lastResult: SprintResult?
    /// The zero-based rank of the just-entered score, once initials are submitted.
    @Published private(set) var placement: Int?
    /// The id of the just-entered leaderboard entry, so the results can highlight it.
    @Published private(set) var lastEntryID: UUID?
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
    private let leaderboard: LeaderboardStore
    private let speech: SpeechRecognizing
    private var timerCancellable: AnyCancellable?

    init(
        words: [Word] = WordBank.all,
        tickInterval: TimeInterval = 1.0 / 30.0,
        autoAdvanceDelay: TimeInterval = 1.8,
        now: @escaping () -> Date = Date.init,
        bestTimes: BestTimeStore = UserDefaultsBestTimeStore(),
        leaderboard: LeaderboardStore = UserDefaultsLeaderboardStore(),
        speech: SpeechRecognizing = SpeechRecognizer()
    ) {
        self.words = words
        self.tickInterval = tickInterval
        self.autoAdvanceDelay = autoAdvanceDelay
        self.now = now
        self.bestTimes = bestTimes
        self.leaderboard = leaderboard
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
            sprint: SprintProgress(
                answered: answeredCount,
                target: config.target,
                totalElapsed: sprintElapsed
            )
        )
    }

    /// Initials to pre-fill the name-entry screen with.
    var suggestedInitials: String {
        leaderboard.lastInitials ?? "AAA"
    }

    /// Configurations that have leaderboard entries, ordered for display.
    func leaderboardConfigs() -> [SprintConfig] {
        leaderboard.configs().sorted {
            ($0.target, $0.waitsEnabled ? 1 : 0) < ($1.target, $1.waitsEnabled ? 1 : 0)
        }
    }

    /// The ranked entries for a configuration.
    func leaderboardEntries(for config: SprintConfig) -> [LeaderboardEntry] {
        leaderboard.entries(for: config)
    }

    // MARK: - Intents

    func startSprint(target: Int, waitsEnabled: Bool = true) {
        start(config: SprintConfig(target: max(1, target), waitsEnabled: waitsEnabled))
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

    /// Record the entered initials against the finished sprint's leaderboard.
    func submitInitials(_ initials: String) {
        guard phase == .nameEntry, let result = lastResult else { return }
        let entry = LeaderboardEntry(
            initials: normalized(initials),
            time: result.totalTime,
            date: now()
        )
        placement = leaderboard.add(entry, config: result.config)
        lastEntryID = entry.id
        phase = .results
    }

    /// Replay the just-finished sprint with the same settings.
    func playAgain() {
        start(config: config)
    }

    /// Open the leaderboard browser from the menu.
    func openLeaderboard() {
        phase = .leaderboard
    }

    /// Return to the menu from the leaderboard browser.
    func closeLeaderboard() {
        phase = .menu
    }

    private func normalized(_ initials: String) -> String {
        let letters = initials.uppercased().filter { $0.isLetter }
        return String(letters.prefix(3))
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

        let total = WaitTimeCalculator.totalTime(previousWait: waitTime, answerTime: answerTime)
        waitTime = WaitTimeCalculator.nextWaitTime(
            correct: correct,
            currentWait: waitTime,
            totalTime: total
        )

        spokenResult = nil
        answerShownAt = nil

        if answeredCount >= config.target {
            finishSprint()
        } else {
            beginNextWord()
        }
    }

    // MARK: - Session lifecycle

    private func start(config: SprintConfig) {
        self.config = config
        waitTime = 0
        answeredCount = 0
        correctCount = 0
        sprintElapsed = 0
        sprintStart = nil
        lastResult = nil
        startTimer()
        beginNextWord()
    }

    private func finishSprint() {
        speech.stop()
        let total = sprintStart.map { now().timeIntervalSince($0) } ?? sprintElapsed
        sprintElapsed = total

        lastResult = SprintResult(
            config: config,
            totalTime: total,
            correctCount: correctCount
        )
        placement = nil
        lastEntryID = nil
        stopTimer()
        phase = .nameEntry
    }

    private func recordWordTime(_ time: TimeInterval) {
        guard fastestWordTime.map({ time < $0 }) ?? true else { return }
        fastestWordTime = time
        bestTimes.fastestWordTime = time
    }

    // MARK: - Phase transitions

    private func beginNextWord() {
        round = Round.random(from: words)
        if config.waitsEnabled, waitTime > 0 {
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
        if sprintStart == nil {
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
        if let sprintStart,
           phase == .question || phase == .waiting || phase == .answer {
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
        case .menu, .nameEntry, .results, .leaderboard:
            break
        }
    }
}
