import Foundation
import Testing
@testable import Que

struct LeaderboardDataTests {
    private let config = SprintConfig(listID: "list.a", target: 10, waitsEnabled: true)

    private func entry(_ initials: String, _ time: TimeInterval) -> LeaderboardEntry {
        LeaderboardEntry(initials: initials, time: time, date: Date(timeIntervalSince1970: 0))
    }

    @Test
    func addSortsByTimeAndReturnsRank() {
        var data = LeaderboardData()
        #expect(data.add(entry("AAA", 30), config: config, title: "A") == 0)
        #expect(data.add(entry("BBB", 20), config: config, title: "A") == 0)
        #expect(data.add(entry("CCC", 25), config: config, title: "A") == 1)

        #expect(data.entries(for: config).map(\.initials) == ["BBB", "CCC", "AAA"])
    }

    @Test
    func separatesByListAndConfiguration() {
        var data = LeaderboardData()
        let otherList = SprintConfig(listID: "list.b", target: 10, waitsEnabled: true)
        let noWaits = SprintConfig(listID: "list.a", target: 10, waitsEnabled: false)

        _ = data.add(entry("AAA", 10), config: config, title: "A")
        _ = data.add(entry("BBB", 5), config: otherList, title: "B")
        _ = data.add(entry("CCC", 7), config: noWaits, title: "A")

        #expect(data.entries(for: config).map(\.initials) == ["AAA"])
        #expect(data.entries(for: otherList).map(\.initials) == ["BBB"])
        #expect(data.entries(for: noWaits).map(\.initials) == ["CCC"])
        #expect(data.summaries().count == 3)
    }

    @Test
    func summariesCarryTheTitle() {
        var data = LeaderboardData()
        _ = data.add(entry("AAA", 10), config: config, title: "Interrogatives")
        let summary = try! #require(data.summaries().first)
        #expect(summary.title == "Interrogatives")
        #expect(summary.config == config)
    }

    @Test
    func remembersLastInitials() {
        var data = LeaderboardData()
        _ = data.add(entry("XYZ", 12), config: config, title: "A")
        #expect(data.lastInitials == "XYZ")
    }
}
