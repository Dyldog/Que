import SwiftUI

/// A ranked list of scores for one configuration, styled like a pinball high-score
/// table. Optionally highlights a freshly entered row.
struct LeaderboardView: View {
    let entries: [LeaderboardEntry]
    var highlightID: UUID?
    var limit: Int = 10

    var body: some View {
        if entries.isEmpty {
            emptyState
        } else {
            VStack(spacing: 6) {
                ForEach(Array(entries.prefix(limit).enumerated()), id: \.element.id) { index, entry in
                    row(rank: index + 1, entry: entry, highlighted: entry.id == highlightID)
                }
            }
        }
    }

    private var emptyState: some View {
        Text("NO SCORES YET")
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }

    private func row(rank: Int, entry: LeaderboardEntry, highlighted: Bool) -> some View {
        let color = highlighted ? ArcadePalette.gold : ArcadePalette.neon
        return HStack(spacing: 14) {
            Text(rankText(rank))
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundStyle(color.opacity(0.9))
                .frame(width: 44, alignment: .leading)
            Text(entry.initials)
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(color)
                .tracking(4)
            Spacer()
            Text(entry.time.stopwatchText)
                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(highlighted ? color.opacity(0.14) : .white.opacity(0.03), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(highlighted ? 0.8 : 0.15), lineWidth: highlighted ? 2 : 1)
        )
        .neonGlow(highlighted ? color : .clear, radius: highlighted ? 10 : 0)
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
