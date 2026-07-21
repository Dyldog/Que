import Foundation

/// Stores ranked high scores, kept separately for each sprint configuration
/// (which includes the list being played).
protocol LeaderboardStore: AnyObject {
    /// Entries for a configuration, fastest first.
    func entries(for config: SprintConfig) -> [LeaderboardEntry]

    /// All boards that have at least one score.
    func boards() -> [LeaderboardBoard]

    /// Records a score. Returns its zero-based rank, or `nil` if it didn't place.
    @discardableResult
    func add(_ entry: LeaderboardEntry, config: SprintConfig, title: String) -> Int?

    /// The initials last entered, used to pre-fill the next entry.
    var lastInitials: String? { get }
}
