import SwiftUI

/// The top-of-screen header: an exit control, live sprint progress (when in a
/// sprint), the current word's stopwatch, and the fastest-word record below it.
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
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
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
        .font(.subheadline.weight(.semibold))
        .monospacedDigit()
        .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private var fastestLabel: some View {
        if let fastest = header.fastestWordTime {
            Label("Fastest \(fastest.stopwatchText)", systemImage: "bolt.fill")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        } else {
            Label("No fastest word yet", systemImage: "bolt")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }
}
