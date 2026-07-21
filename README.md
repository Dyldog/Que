# Que

A pinball-arcade-styled iOS vocabulary trainer. Pick a word list, race a **Sprint**
for your fastest time, then punch your three initials into the leaderboard.

## Word lists

Choose a list from the menu's **LIST** selector:

- **Bundled** lists compiled into the app (Interrogatives, Numbers, Colours, Days &
  Months, Common Verbs) — see [`BundledLists`](Que/Sources/Models/BundledLists.swift).
- **Custom** lists you build in the app (name, both languages, and word pairs).
- **Generated** lists, where the "list" is really a *prompt*: its words are generated
  on-device at the **start of each round** with Apple's Foundation Models
  (`@Generable`) and never saved. The prompt and its languages are saved so it stays
  selectable and keeps its own leaderboard. See
  [`FoundationModelsWordListGenerator`](Que/Sources/Shared/Generation/FoundationModelsWordListGenerator.swift).

Custom and prompt lists persist via [`WordListStore`](Que/Sources/Shared/Persistence/WordListStore.swift).

## How it works

From the menu you pick a list, how many questions (10 / 50 / 100 / custom), and
whether the adaptive wait is on (it is by default), then hit **START**.

1. A word appears in English or Spanish while a stopwatch ticks upward. The fastest
   single-word recall so far is shown just below it as a target to beat.
2. **Say the translation out loud.** The app listens and grades you automatically:
   the moment it hears the right word it marks you **Correct**; tap **I don't know**
   to give up (counts as incorrect). Matching ignores case, accents, punctuation and
   parenthetical qualifiers, and accepts the answer inside a longer phrase — see
   [`AnswerMatcher`](Que/Sources/Shared/Speech/AnswerMatcher.swift).
3. If microphone/speech permission is denied, it falls back to tap-to-reveal with
   manual grade buttons.
4. When the adaptive wait is on, you wait before the next word — a glowing countdown
   ring shows the remaining time, and a beep + vibration fire when it ends.
5. When the sprint ends you enter three initials on an arcade name-entry screen, and
   your time is saved to the leaderboard for that exact configuration.

Speech uses `SFSpeechRecognizer` (Spanish or English depending on the answer
language) behind the [`SpeechRecognizing`](Que/Sources/Shared/Speech/SpeechRecognizing.swift)
protocol, so the view model is tested with a fake recognizer.

### Leaderboards

Scores are kept **separately for every configuration** — that's the list (or prompt)
× question count × wait on/off. Browse them all from the menu's **HIGH SCORES** button.
Persistence and ranking live in
[`LeaderboardStore`](Que/Sources/Shared/Persistence/LeaderboardStore.swift) /
[`LeaderboardData`](Que/Sources/Shared/Persistence/LeaderboardData.swift).

### Adaptive timing

- **Total time** for a round = the wait that preceded the word + the time taken to answer.
- **Correct** → next wait time is halved (`total / 2`).
- **Incorrect** → next wait time is at least doubled (`max(total * 2, currentWait * 2)`).

The first word has no wait, so it appears immediately. The rules live in
[`WaitTimeCalculator`](Que/Sources/Shared/Timing/WaitTimeCalculator.swift) and are unit tested.

### Look

Every screen sits on a shared neon [`PinballBackground`](Que/Sources/Screens/Quiz/Components/PinballBackground.swift)
with glowing monospaced type, using the palette and helpers in `ArcadePalette`,
`NeonButtonStyle`, and `PinballPanel`.

## Project layout

```
Que/Sources/
  App/            App entry point
  Models/         Word, WordBank, Language, Round, SprintConfig, SprintResult
  Shared/         Timing, formatting, speech, and persistence (best time + leaderboard)
  Screens/Quiz/   The single screen: QuizView, QuizViewModel, and its Components
Que/Tests/        Unit tests
```

## Building & running

Project files are generated with [Tuist](https://tuist.io):

```sh
tuist generate
xcodebuild -workspace Que.xcworkspace -scheme Que \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Regenerate with `tuist generate` after adding or removing source files.
