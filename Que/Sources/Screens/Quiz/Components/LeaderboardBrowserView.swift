import SwiftUI

/// Browses every leaderboard, one section per configuration (list × count × waits),
/// reached from the menu.
struct LeaderboardBrowserView: View {
    let boards: [LeaderboardBoard]
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: "HIGH SCORES", onBack: onBack)
            if boards.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 22) {
                ForEach(boards) { board in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title(for: board))
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundStyle(ArcadePalette.gold)
                            .lineLimit(2)
                        LeaderboardView(entries: board.entries)
                    }
                    .padding(16)
                    .pinballPanel()
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("NO SCORES YET")
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
            Text("Play a sprint to set a record")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.35))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func title(for board: LeaderboardBoard) -> String {
        let config = board.config
        return "\(board.title.uppercased()) · \(config.target) · \(config.waitsEnabled ? "WAITS" : "NO WAITS")"
    }
}
