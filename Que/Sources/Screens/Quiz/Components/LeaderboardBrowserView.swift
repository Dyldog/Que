import SwiftUI

/// Browses every leaderboard, one section per configuration, reached from the menu.
struct LeaderboardBrowserView: View {
    let configs: [SprintConfig]
    let entries: (SprintConfig) -> [LeaderboardEntry]
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar
            if configs.isEmpty {
                emptyState
            } else {
                boards
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var topBar: some View {
        ZStack {
            Text("HIGH SCORES")
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(ArcadePalette.hot)
                .neonGlow(ArcadePalette.hot, radius: 10)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.black))
                        .foregroundStyle(ArcadePalette.neon)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var boards: some View {
        ScrollView {
            VStack(spacing: 22) {
                ForEach(configs, id: \.self) { config in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title(for: config))
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundStyle(ArcadePalette.gold)
                        LeaderboardView(entries: entries(config))
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

    private func title(for config: SprintConfig) -> String {
        "\(config.target) QUESTIONS · \(config.waitsEnabled ? "WAITS ON" : "NO WAITS")"
    }
}
