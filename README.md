# Que

An iOS app to practise the Spanish interrogative words with an adaptive, self-graded
flashcard loop.

## How it works

From the menu you choose a mode and whether the adaptive wait is on (it is by default).

1. A word appears in English or Spanish while a stopwatch ticks upward. The
   fastest single-word recall so far is shown just below it as a target to beat.
2. Tap anywhere to reveal the translation, then grade yourself **Correct** or **Incorrect**.
3. When the adaptive wait is on, you are made to wait before the next word — a
   countdown ring shows the remaining time, and a beep + vibration fire when it ends.

### Modes

- **Practice** — endless.
- **Sprint** — race to answer a fixed number of questions (10 / 50 / 100 / custom)
  in the shortest total time. Your best time per length is saved and shown as a
  target. The wait toggle applies here too, so waits count against your total.

The **Wait time between words** toggle on the menu applies to both modes.

### Adaptive timing

- **Total time** for a round = the wait that preceded the word + the time taken to answer.
- **Correct** → next wait time is halved (`total / 2`).
- **Incorrect** → next wait time is at least doubled (`max(total * 2, currentWait * 2)`).

The first word has no wait, so it appears immediately. The rules live in
[`WaitTimeCalculator`](Que/Sources/Shared/Timing/WaitTimeCalculator.swift) and are unit tested.

### Records

Personal bests (fastest word, best sprint time per length) persist between launches
via [`BestTimeStore`](Que/Sources/Shared/Persistence/BestTimeStore.swift).

## Project layout

```
Que/Sources/
  App/            App entry point
  Models/         Word, WordBank, Language, Round
  Shared/         Cross-screen helpers (timing, formatting)
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
