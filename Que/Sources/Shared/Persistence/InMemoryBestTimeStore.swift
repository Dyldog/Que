import Foundation

/// A non-persistent `BestTimeStore` for tests and SwiftUI previews.
final class InMemoryBestTimeStore: BestTimeStore {
    var fastestWordTime: TimeInterval?

    init(fastestWordTime: TimeInterval? = nil) {
        self.fastestWordTime = fastestWordTime
    }
}
