import Foundation

/// A non-persistent `BestTimeStore` for tests and SwiftUI previews.
final class InMemoryBestTimeStore: BestTimeStore {
    var fastestWordTime: TimeInterval?
    private var sprintTimes: [Int: TimeInterval] = [:]

    init(fastestWordTime: TimeInterval? = nil, sprintTimes: [Int: TimeInterval] = [:]) {
        self.fastestWordTime = fastestWordTime
        self.sprintTimes = sprintTimes
    }

    func bestSprintTime(target: Int) -> TimeInterval? {
        sprintTimes[target]
    }

    func setBestSprintTime(_ time: TimeInterval, target: Int) {
        sprintTimes[target] = time
    }
}
