import Foundation

/// The configurable options that define a distinct leaderboard: how many
/// questions, and whether the adaptive wait was enabled.
struct SprintConfig: Hashable, Codable {
    let target: Int
    let waitsEnabled: Bool
}
