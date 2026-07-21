import SwiftUI

/// The top-of-screen header: a quit control, live sprint progress, the current
/// word's stopwatch, and the fastest-word record below it.
struct SessionHeaderView: View {
    let header: SessionHeader
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            topBar
            StopwatchLabel(elapsed: header.elapsed)
            fastestLabel
        }
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

            if let sprint = header.sprint {
                sprintProgress(sprint)
            }
        }
    }

    private func sprintProgress(_ sprint: SprintProgress) -> some View {
        HStack(spacing: 12) {
            Label("\(sprint.answered)/\(sprint.target)", systemImage: "list.number")
            Label(sprint.totalElapsed.stopwatchText, systemImage: "timer")
        }
        .font(.system(size: 15, weight: .black, design: .monospaced))
        .foregroundStyle(ArcadePalette.neon)
    }

    @ViewBuilder
    private var fastestLabel: some View {
        if let fastest = header.fastestWordTime {
            label("FASTEST \(fastest.stopwatchText)", icon: "bolt.fill")
        } else {
            label("NO FASTEST YET", icon: "bolt")
        }
    }

    private func label(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundStyle(ArcadePalette.gold.opacity(0.8))
    }
}
