import SwiftUI

/// The forced wait between words: a countdown ring with the seconds remaining.
/// The word is deliberately hidden here so it can't be studied early.
struct WaitingView: View {
    let remaining: TimeInterval
    let total: TimeInterval
    let onExit: () -> Void

    private var progress: Double {
        guard total > 0 else { return 1 }
        return min(1, max(0, 1 - remaining / total))
    }

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Button(action: onExit) {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Quit to menu")
                Spacer()
            }
            .padding(.top, 8)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: progress)
                Text(remaining.stopwatchText)
                    .font(.system(size: 52, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
            }
            .frame(width: 220, height: 220)

            Text("Get ready…")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
