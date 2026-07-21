import Foundation

/// A leaderboard for one configuration, with a display title.
struct LeaderboardBoard: Identifiable, Equatable {
    let config: SprintConfig
    let title: String
    let entries: [LeaderboardEntry]

    var id: SprintConfig { config }
}

/// The persisted leaderboard state: one board of ranked entries per configuration,
/// plus the last initials entered. This value type holds the ranking logic so the
/// concrete stores stay thin.
struct LeaderboardData: Equatable, Codable {
    struct Board: Equatable, Codable {
        var listID: String
        var target: Int
        var waitsEnabled: Bool
        var title: String
        var entries: [LeaderboardEntry]

        var config: SprintConfig {
            SprintConfig(listID: listID, target: target, waitsEnabled: waitsEnabled)
        }
    }

    var boards: [Board] = []
    var lastInitials: String?

    /// The most a single board keeps.
    static let maxPerBoard = 100

    func entries(for config: SprintConfig) -> [LeaderboardEntry] {
        board(for: config)?.entries ?? []
    }

    func summaries() -> [LeaderboardBoard] {
        boards.map { LeaderboardBoard(config: $0.config, title: $0.title, entries: $0.entries) }
    }

    /// Inserts an entry into the board for `config`, keeping entries sorted fastest
    /// first. Returns the zero-based rank of the inserted entry, or `nil` if it did
    /// not make the board.
    mutating func add(_ entry: LeaderboardEntry, config: SprintConfig, title: String) -> Int? {
        lastInitials = entry.initials

        if let index = boards.firstIndex(where: { $0.config == config }) {
            boards[index].title = title
            boards[index].entries.append(entry)
            boards[index].entries.sort { $0.time < $1.time }
            if boards[index].entries.count > Self.maxPerBoard {
                boards[index].entries.removeLast(boards[index].entries.count - Self.maxPerBoard)
            }
            return boards[index].entries.firstIndex { $0.id == entry.id }
        } else {
            boards.append(Board(
                listID: config.listID,
                target: config.target,
                waitsEnabled: config.waitsEnabled,
                title: title,
                entries: [entry]
            ))
            return 0
        }
    }

    private func board(for config: SprintConfig) -> Board? {
        boards.first { $0.config == config }
    }
}
