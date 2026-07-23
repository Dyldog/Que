import Combine
import Foundation

/// Drives a sprint over a chosen word list: a state machine over the phases of a
/// round plus the stopwatch, the optional adaptive wait, the fastest-word record,
/// sprint progress, list management, generation, and leaderboard name entry.
@MainActor
final class QuizViewModel: ObservableObject {

    enum Phase: Equatable {
        case menu
        /// Choosing which list to play.
        case listPicker
        /// Building or editing a custom / prompt list.
        case listEditor
        /// Generating a prompt list's words at the start of a round.
        case generating
        case waiting
        case question
        case answer
        /// Entering three initials for the leaderboard after a finished sprint.
        case nameEntry
        case results
        /// Browsing the leaderboards from the menu.
        case leaderboard
    }

    @Published private(set) var phase: Phase = .menu
    @Published private(set) var config = SprintConfig(listID: "", target: 10, waitsEnabled: true)
    @Published private(set) var selectedList: WordList
    @Published private(set) var userLists: [WordList] = []
    @Published private(set) var bundledJSONLists: [WordList] = []
    @Published var editingList: WordList?
    @Published private(set) var generationError: String?

    @Published private(set) var round: Round?
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var waitRemaining: TimeInterval = 0
    @Published private(set) var fastestWordTime: TimeInterval?
    @Published private(set) var lastResult: SprintResult?
    @Published private(set) var placement: Int?
    @Published private(set) var lastEntryID: UUID?
    @Published private(set) var waitEndedSignal = 0
    @Published private(set) var speechEnabled = false
    @Published private(set) var transcript = ""
    @Published private(set) var spokenResult: Bool?

    let bundledLists = BundledLists.all
    private let bundledJSONStore = BundledJSONWordListStore()
    var bundledJSONLists: [WordList] { bundledJSONStore.userLists() }

    private var answeredCount = 0
    private var correctCount = 0
    private var sprintElapsed: TimeInterval = 0
    private var activeTitle = ""
    private var activeWords: [Word] = []
    private var activeFront = Language.spanish
    private var activeBack = Language.english

    private(set) var waitTime: TimeInterval = 0

    private var questionStart: Date?
    private var answerTime: TimeInterval = 0
    private var waitEnd: Date?
    private var sprintStart: Date?
    private var answerShownAt: Date?
    private var generationTask: Task<Void, Never>?

    private let now: () -> Date
    private let tickInterval: TimeInterval
    private let autoAdvanceDelay: TimeInterval
    private let bestTimes: BestTimeStore
    private let leaderboard: LeaderboardStore
    private let wordLists: WordListStore
    private let generator: WordListGenerating
    private let speech: SpeechRecognizing
    private var timerCancellable: AnyCancellable?

    init(
        tickInterval: TimeInterval = 1.0 / 30.0,
        autoAdvanceDelay: TimeInterval = 1.8,
        now: @escaping () -> Date = Date.init,
        bestTimes: BestTimeStore = UserDefaultsBestTimeStore(),
        leaderboard: LeaderboardStore = UserDefaultsLeaderboardStore(),
        wordLists: WordListStore = UserDefaultsWordListStore(),
        generator: WordListGenerating = FoundationModelsWordListGenerator(),
        speech: SpeechRecognizing = SpeechRecognizer()
    ) {
        self.tickInterval = tickInterval
        self.autoAdvanceDelay = autoAdvanceDelay
        self.now = now
        self.bestTimes = bestTimes
        self.leaderboard = leaderboard
        self.wordLists = wordLists
        self.generator = generator
        self.speech = speech
        self.fastestWordTime = bestTimes.fastestWordTime
        self.selectedList = BundledLists.all[0]
        self.userLists = wordLists.userLists()
        self.bundledJSONLists = loadBundledJSONLists()
    }
    
    private func loadBundledJSONLists() -> [WordList] {
        let store = BundledJSONWordListStore()
        return store.userLists()
    }

    /// Resolves microphone/speech permission once, before playing.
    func prepare() async {
        let granted = await speech.requestAuthorization()
        speechEnabled = granted && speech.isAvailable
    }

    var header: SessionHeader {
        SessionHeader(
            elapsed: elapsed,
            fastestWordTime: fastestWordTime,
            sprint: SprintProgress(answered: answeredCount, target: config.target, totalElapsed: sprintElapsed)
        )
    }

    var suggestedInitials: String { leaderboard.lastInitials ?? "AAA" }
    var generationAvailable: Bool { generator.isAvailable }
    var allLists: [WordList] { bundledLists + bundledJSONLists + userLists }

    func leaderboardBoards() -> [LeaderboardBoard] {
        leaderboard.boards().sorted {
            ($0.title, $0.config.target, $0.config.waitsEnabled ? 1 : 0)
                < ($1.title, $1.config.target, $1.config.waitsEnabled ? 1 : 0)
        }
    }

    func leaderboardEntries(for config: SprintConfig) -> [LeaderboardEntry] {
        leaderboard.entries(for: config)
    }

    // MARK: - List selection & management

    func openListPicker() {
        generationError = nil
        phase = .listPicker
    }

    func selectList(_ list: WordList) {
        selectedList = list
        phase = .menu
    }

    func createList(kind: WordList.Kind) {
        editingList = WordList(
            name: "",
            kind: kind,
            front: .spanish,
            back: .english,
            words: kind == .custom ? [Word(front: "", back: "")] : [],
            prompt: kind == .prompt ? "" : nil
        )
        phase = .listEditor
    }

    func editList(_ list: WordList) {
        editingList = list
        phase = .listEditor
    }

    func saveList(_ list: WordList) {
        wordLists.save(list)
        userLists = wordLists.userLists()
        selectedList = list
        editingList = nil
        phase = .listPicker
    }

    func deleteList(_ list: WordList) {
        wordLists.delete(id: list.id)
        userLists = wordLists.userLists()
        if selectedList.id == list.id {
            selectedList = bundledLists[0]
        }
        editingList = nil
        phase = .listPicker
    }

    func cancelEditing() {
        editingList = nil
        phase = .listPicker
    }

    func backToMenu() {
        phase = .menu
    }

    // MARK: - Intents

    func startSprint(target: Int, waitsEnabled: Bool) {
        generationError = nil
        let list = selectedList
        let config = SprintConfig(listID: list.id, target: max(1, target), waitsEnabled: waitsEnabled)

        if list.isGenerated {
            beginGenerated(list: list, config: config)
        } else {
            begin(config: config, title: list.name, words: list.words, front: list.front, back: list.back)
        }
    }

    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
        phase = .menu
    }

    /// Awaits any in-flight generation. Intended for tests.
    func awaitGeneration() async {
        await generationTask?.value
    }

    func reveal() {
        guard phase == .question, let questionStart else { return }
        answerTime = now().timeIntervalSince(questionStart)
        elapsed = answerTime
        recordWordTime(answerTime)
        spokenResult = nil
        phase = .answer
    }

    func giveUp() {
        autoGrade(correct: false)
    }

    func grade(correct: Bool) {
        guard phase == .answer, spokenResult == nil else { return }
        commitGrade(correct: correct)
    }

    func returnToMenu() {
        speech.stop()
        stopTimer()
        generationTask?.cancel()
        round = nil
        phase = .menu
    }

    func submitInitials(_ initials: String) {
        guard phase == .nameEntry, let result = lastResult else { return }
        let entry = LeaderboardEntry(initials: normalized(initials), time: result.totalTime, date: now())
        placement = leaderboard.add(entry, config: result.config, title: result.title)
        lastEntryID = entry.id
        phase = .results
    }

    func playAgain() {
        startSprint(target: config.target, waitsEnabled: config.waitsEnabled)
    }

    func openLeaderboard() {
        phase = .leaderboard
    }

    func closeLeaderboard() {
        phase = .menu
    }

    private func normalized(_ initials: String) -> String {
        String(initials.uppercased().filter { $0.isLetter }.prefix(3))
    }

    // MARK: - Generation

    private func beginGenerated(list: WordList, config: SprintConfig) {
        phase = .generating
        let front = list.front
        let back = list.back
        let promptText = list.prompt?.isEmpty == false ? list.prompt! : list.name
        let count = generationCount(for: config.target)

        generationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let words = try await self.generator.generate(prompt: promptText, front: front, back: back, count: count)
                guard !Task.isCancelled else { return }
                self.begin(config: config, title: list.name, words: words, front: front, back: back)
            } catch {
                guard !Task.isCancelled else { return }
                self.generationError = self.message(for: error)
                self.phase = .menu
            }
        }
    }

    private func generationCount(for target: Int) -> Int {
        min(max(target, 12), 24)
    }

    private func message(for error: Error) -> String {
        switch error {
        case WordListGenerationError.unavailable:
            "Generation isn’t available on this device."
        default:
            "Couldn’t generate this list. Please try again."
        }
    }

    // MARK: - Session lifecycle

    private func begin(config: SprintConfig, title: String, words: [Word], front: Language, back: Language) {
        guard !words.isEmpty else {
            generationError = "“\(title)” has no words yet."
            phase = .menu
            return
        }
        self.config = config
        activeTitle = title
        activeWords = words
        activeFront = front
        activeBack = back
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

        lastResult = SprintResult(config: config, title: activeTitle, totalTime: total, correctCount: correctCount)
        placement = nil
        lastEntryID = nil
        stopTimer()
        // Only a flawless sprint earns a spot on the leaderboard; anything less
        // skips straight to the results.
        phase = correctCount >= config.target ? .nameEntry : .results
    }

    private func recordWordTime(_ time: TimeInterval) {
        guard fastestWordTime.map({ time < $0 }) ?? true else { return }
        fastestWordTime = time
        bestTimes.fastestWordTime = time
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

    private func commitGrade(correct: Bool) {
        answeredCount += 1
        if correct { correctCount += 1 }

        let total = WaitTimeCalculator.totalTime(previousWait: waitTime, answerTime: answerTime)
        waitTime = WaitTimeCalculator.nextWaitTime(correct: correct, currentWait: waitTime, totalTime: total)

        spokenResult = nil
        answerShownAt = nil

        if answeredCount >= config.target {
            finishSprint()
        } else {
            beginNextWord()
        }
    }

    // MARK: - Phase transitions

    private func beginNextWord() {
        guard let next = Round.random(from: activeWords, front: activeFront, back: activeBack) else {
            returnToMenu()
            return
        }
        round = next
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
        if sprintStart == nil { sprintStart = start }
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
            .sink { [weak self] _ in self?.tick() }
    }

    private func stopTimer() {
        timerCancellable = nil
    }

    private func tick() {
        if let sprintStart, phase == .question || phase == .waiting || phase == .answer {
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
            if let result = spokenResult, let answerShownAt,
               now().timeIntervalSince(answerShownAt) >= autoAdvanceDelay {
                commitGrade(correct: result)
            }
        case .menu, .listPicker, .listEditor, .generating, .nameEntry, .results, .leaderboard:
            break
        }
    }
}
