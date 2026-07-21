import Foundation

/// Stores ranked high scores, kept separately for each sprint configuration.
protocol LeaderboardStore: AnyObject {
    /// Entries for a configuration, fastest first.
    func entries(for config: SprintConfig) -> [LeaderboardEntry]

    /// All configurations that have at least one score.
    func configs() -> [SprintConfig]

    /// Records a score. Returns its zero-based rank, or `nil` if it didn't place.
    @discardableResult
    func add(_ entry: LeaderboardEntry, config: SprintConfig) -> Int?

    /// The initials last entered, used to pre-fill the next entry.
    var lastInitials: String? { get }
}
