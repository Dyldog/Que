import Foundation

/// A single leaderboard score: three initials and the total time achieved.
struct LeaderboardEntry: Identifiable, Equatable, Codable {
    let id: UUID
    let initials: String
    let time: TimeInterval
    let date: Date

    init(id: UUID = UUID(), initials: String, time: TimeInterval, date: Date) {
        self.id = id
        self.initials = initials
        self.time = time
        self.date = date
    }
}
