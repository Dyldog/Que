import SwiftUI

/// The upward-ticking stopwatch, shown like a glowing arcade score readout.
struct StopwatchLabel: View {
    let elapsed: TimeInterval

    var body: some View {
        Text(elapsed.stopwatchText)
            .font(.system(size: 46, weight: .black, design: .monospaced))
            .foregroundStyle(.white)
            .neonGlow(ArcadePalette.neon, radius: 8)
            .monospacedDigit()
            .contentTransition(.numericText(value: elapsed))
            .accessibilityLabel("Elapsed time")
    }
}
