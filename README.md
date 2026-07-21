# Que

An iOS app to practise the Spanish interrogative words with an adaptive, self-graded
flashcard loop.

## How it works

1. Tap **Start**.
2. A word appears in English or Spanish while a stopwatch ticks upward.
3. Tap anywhere to reveal the translation, then grade yourself **Correct** or **Incorrect**.
4. You are made to wait before the next word — a countdown ring shows the remaining time.

### Adaptive timing

- **Total time** for a round = the wait that preceded the word + the time taken to answer.
- **Correct** → next wait time is halved (`total / 2`).
- **Incorrect** → next wait time is at least doubled (`max(total * 2, currentWait * 2)`).

The first word has no wait, so it appears immediately. The rules live in
[`WaitTimeCalculator`](Que/Sources/Shared/Timing/WaitTimeCalculator.swift) and are unit tested.

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
