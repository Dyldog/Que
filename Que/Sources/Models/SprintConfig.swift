import Foundation

/// The configurable options that define a distinct leaderboard: which list, how
/// many questions, and whether the adaptive wait was enabled.
struct SprintConfig: Hashable, Codable {
    let listID: String
    let target: Int
    let waitsEnabled: Bool
}
