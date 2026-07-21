import Foundation

/// The persisted leaderboard state: one board of ranked entries per configuration,
/// plus the last initials entered (to pre-fill the next entry). This value type
/// holds the ranking logic so the concrete stores stay thin.
struct LeaderboardData: Equatable, Codable {
    struct Board: Equatable, Codable {
        var target: Int
        var waitsEnabled: Bool
        var entries: [LeaderboardEntry]
    }

    var boards: [Board] = []
    var lastInitials: String?

    /// The most a single board keeps.
    static let maxPerBoard = 100

    func entries(for config: SprintConfig) -> [LeaderboardEntry] {
        board(for: config)?.entries ?? []
    }

    func configs() -> [SprintConfig] {
        boards.map { SprintConfig(target: $0.target, waitsEnabled: $0.waitsEnabled) }
    }

    /// Inserts an entry into the board for `config`, keeping entries sorted fastest
    /// first. Returns the zero-based rank of the inserted entry, or `nil` if it did
    /// not make the board.
    mutating func add(_ entry: LeaderboardEntry, config: SprintConfig) -> Int? {
        lastInitials = entry.initials

        let index = boards.firstIndex { $0.target == config.target && $0.waitsEnabled == config.waitsEnabled }
        if let index {
            boards[index].entries.append(entry)
            boards[index].entries.sort { $0.time < $1.time }
            if boards[index].entries.count > Self.maxPerBoard {
                boards[index].entries.removeLast(boards[index].entries.count - Self.maxPerBoard)
            }
            return boards[index].entries.firstIndex { $0.id == entry.id }
        } else {
            boards.append(Board(target: config.target, waitsEnabled: config.waitsEnabled, entries: [entry]))
            return 0
        }
    }

    private func board(for config: SprintConfig) -> Board? {
        boards.first { $0.target == config.target && $0.waitsEnabled == config.waitsEnabled }
    }
}
