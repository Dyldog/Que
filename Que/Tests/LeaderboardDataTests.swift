import Foundation
import Testing
@testable import Que

struct LeaderboardDataTests {
    private let config = SprintConfig(target: 10, waitsEnabled: true)

    private func entry(_ initials: String, _ time: TimeInterval) -> LeaderboardEntry {
        LeaderboardEntry(initials: initials, time: time, date: Date(timeIntervalSince1970: 0))
    }

    @Test
    func addSortsByTimeAndReturnsRank() {
        var data = LeaderboardData()
        #expect(data.add(entry("AAA", 30), config: config) == 0)
        #expect(data.add(entry("BBB", 20), config: config) == 0) // fastest → top
        #expect(data.add(entry("CCC", 25), config: config) == 1) // between

        #expect(data.entries(for: config).map(\.initials) == ["BBB", "CCC", "AAA"])
    }

    @Test
    func separatesConfigurations() {
        var data = LeaderboardData()
        let noWaits = SprintConfig(target: 10, waitsEnabled: false)

        _ = data.add(entry("AAA", 10), config: config)
        _ = data.add(entry("BBB", 5), config: noWaits)

        #expect(data.entries(for: config).map(\.initials) == ["AAA"])
        #expect(data.entries(for: noWaits).map(\.initials) == ["BBB"])
        #expect(Set(data.configs()) == [config, noWaits])
    }

    @Test
    func remembersLastInitials() {
        var data = LeaderboardData()
        _ = data.add(entry("XYZ", 12), config: config)
        #expect(data.lastInitials == "XYZ")
    }

    @Test
    func unknownConfigurationHasNoEntries() {
        let data = LeaderboardData()
        #expect(data.entries(for: config).isEmpty)
        #expect(data.configs().isEmpty)
    }
}
