import SwiftUI

/// The end-of-sprint screen: the total time, accuracy, best-time comparison,
/// and controls to go again or return to the menu.
struct ResultsView: View {
    let result: SprintResult
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(result.isNewBest ? "New best! 🎉" : "Done!")
                .font(.largeTitle.weight(.bold))

            Text(result.totalTime.stopwatchText)
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .monospacedDigit()

            stats

            Spacer()

            buttons
        }
        .padding()
    }

    private var stats: some View {
        VStack(spacing: 8) {
            Label("\(result.correctCount)/\(result.target) correct", systemImage: "checkmark.circle.fill")
            Label("\(result.target) questions", systemImage: "list.number")
            if let previousBest = result.previousBest {
                Label(
                    result.isNewBest ? "Previous best \(previousBest.stopwatchText)"
                                     : "Best \(previousBest.stopwatchText)",
                    systemImage: "trophy.fill"
                )
            }
        }
        .font(.headline)
        .foregroundStyle(.secondary)
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button(action: onPlayAgain) {
                Text("Go again")
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            .buttonStyle(.borderedProminent)

            Button(action: onMenu) {
                Text("Menu")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ResultsView(
        result: SprintResult(
            target: 10,
            totalTime: 38.4,
            correctCount: 9,
            previousBest: 42.5,
            isNewBest: true
        ),
        onPlayAgain: {},
        onMenu: {}
    )
}
