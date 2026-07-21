import Foundation

/// A `LeaderboardStore` that persists to `UserDefaults` as a single JSON blob.
final class UserDefaultsLeaderboardStore: LeaderboardStore {
    private let defaults: UserDefaults
    private let key = "leaderboard.v2"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func entries(for config: SprintConfig) -> [LeaderboardEntry] {
        load().entries(for: config)
    }

    func boards() -> [LeaderboardBoard] {
        load().summaries()
    }

    @discardableResult
    func add(_ entry: LeaderboardEntry, config: SprintConfig, title: String) -> Int? {
        var data = load()
        let rank = data.add(entry, config: config, title: title)
        save(data)
        return rank
    }

    var lastInitials: String? {
        load().lastInitials
    }

    private func load() -> LeaderboardData {
        guard let raw = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(LeaderboardData.self, from: raw) else {
            return LeaderboardData()
        }
        return decoded
    }

    private func save(_ data: LeaderboardData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: key)
    }
}
