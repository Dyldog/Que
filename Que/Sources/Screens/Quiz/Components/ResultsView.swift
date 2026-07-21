import SwiftUI

/// The end-of-sprint screen: the total time, placement, and this configuration's
/// leaderboard with the new entry highlighted.
struct ResultsView: View {
    let result: SprintResult
    let placement: Int?
    let entries: [LeaderboardEntry]
    let highlightID: UUID?
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            headline
            scoreboard
            LeaderboardView(entries: entries, highlightID: highlightID)
                .padding(16)
                .pinballPanel()
            Spacer(minLength: 8)
            buttons
        }
        .padding()
    }

    private var headline: some View {
        Text(placement == 0 ? "NEW CHAMPION!" : "GAME OVER")
            .font(.system(size: 30, weight: .black, design: .monospaced))
            .foregroundStyle(placement == 0 ? ArcadePalette.gold : ArcadePalette.hot)
            .neonGlow(placement == 0 ? ArcadePalette.gold : ArcadePalette.hot, radius: 12)
            .multilineTextAlignment(.center)
            .padding(.top, 12)
    }

    private var scoreboard: some View {
        VStack(spacing: 4) {
            Text(result.title.uppercased())
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundStyle(ArcadePalette.neon.opacity(0.8))
                .lineLimit(1)
            Text(result.totalTime.stopwatchText)
                .font(.system(size: 60, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .neonGlow(ArcadePalette.neon, radius: 12)
            if let placement {
                Text("\(rankText(placement + 1)) PLACE")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundStyle(ArcadePalette.gold)
            }
            Text("\(result.correctCount)/\(result.config.target) CORRECT")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button("PLAY AGAIN", action: onPlayAgain)
                .buttonStyle(.neon())
            Button("MENU", action: onMenu)
                .buttonStyle(.neon(ArcadePalette.hot, filled: false))
        }
    }

    private func rankText(_ rank: Int) -> String {
        switch rank {
        case 1: "1ST"
        case 2: "2ND"
        case 3: "3RD"
        default: "\(rank)TH"
        }
    }
}

#Preview {
    ZStack {
        PinballBackground()
        ResultsView(
            result: SprintResult(
                config: SprintConfig(listID: "x", target: 10, waitsEnabled: true),
                title: "Interrogatives",
                totalTime: 38.4,
                correctCount: 9
            ),
            placement: 0,
            entries: [
                LeaderboardEntry(initials: "DJE", time: 38.4, date: .now),
                LeaderboardEntry(initials: "ABC", time: 51.0, date: .now),
            ],
            highlightID: nil,
            onPlayAgain: {},
            onMenu: {}
        )
    }
}
