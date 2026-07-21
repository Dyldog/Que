import Foundation

/// The outcome of a finished sprint, before a leaderboard name is entered.
struct SprintResult: Equatable {
    let config: SprintConfig
    let totalTime: TimeInterval
    let correctCount: Int
}
