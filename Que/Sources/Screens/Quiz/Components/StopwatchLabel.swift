import SwiftUI

/// The upward-ticking stopwatch shown at the top of the screen while answering.
struct StopwatchLabel: View {
    let elapsed: TimeInterval

    var body: some View {
        Text(elapsed.stopwatchText)
            .font(.system(size: 44, weight: .medium, design: .monospaced))
            .foregroundStyle(.secondary)
            .monospacedDigit()
            .contentTransition(.numericText(value: elapsed))
            .accessibilityLabel("Elapsed time")
    }
}
