import Foundation
@testable import Que

/// A controllable `WordListGenerating` for tests.
final class FakeWordListGenerator: WordListGenerating {
    var isAvailable: Bool
    var result: [Word]
    var error: Error?

    init(result: [Word] = [], isAvailable: Bool = true, error: Error? = nil) {
        self.result = result
        self.isAvailable = isAvailable
        self.error = error
    }

    func generate(prompt: String, front: Language, back: Language, count: Int) async throws -> [Word] {
        if let error { throw error }
        return result
    }
}
