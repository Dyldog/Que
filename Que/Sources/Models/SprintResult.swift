import Foundation

/// The outcome of a finished sprint.
struct SprintResult: Equatable {
    let target: Int
    let totalTime: TimeInterval
    let correctCount: Int
    /// The best time for this target before this run, if any.
    let previousBest: TimeInterval?
    /// Whether this run beat (or set) the best time for its target.
    let isNewBest: Bool
}
