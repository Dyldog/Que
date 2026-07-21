import Foundation

/// The outcome of a finished sprint, before a leaderboard name is entered.
struct SprintResult: Equatable {
    let config: SprintConfig
    /// The display name of the list played (for the leaderboard and results).
    let title: String
    let totalTime: TimeInterval
    let correctCount: Int
}
