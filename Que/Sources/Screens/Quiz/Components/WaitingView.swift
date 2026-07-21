import SwiftUI

/// The forced wait between words: a glowing neon countdown ring. The word is
/// deliberately hidden here so it can't be studied early.
struct WaitingView: View {
    let remaining: TimeInterval
    let total: TimeInterval
    let onExit: () -> Void

    private let neon = ArcadePalette.neon

    private var progress: Double {
        guard total > 0 else { return 1 }
        return min(1, max(0, 1 - remaining / total))
    }

    var body: some View {
        VStack(spacing: 32) {
            topBar
            Spacer()
            ring
            Text("GET READY")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundStyle(neon)
                .tracking(4)
                .neonGlow(neon, radius: 8)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var topBar: some View {
        HStack {
            Button(action: onExit) {
                Image(systemName: "xmark")
                    .font(.title3.weight(.black))
                    .foregroundStyle(ArcadePalette.hot)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Quit to menu")
            Spacer()
        }
        .padding(.top, 8)
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.08), lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(neon, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .neonGlow(neon, radius: 14)
                .animation(.linear(duration: 0.1), value: progress)
            Text(remaining.stopwatchText)
                .font(.system(size: 54, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .neonGlow(neon, radius: 8)
        }
        .frame(width: 230, height: 230)
    }
}
