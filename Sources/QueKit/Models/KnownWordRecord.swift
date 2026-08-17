import Foundation

/// A vocabulary pair the learner has answered correctly at least once in Que.
public struct KnownWordRecord: Codable, Hashable, Sendable {
    public var front: String
    public var back: String
    public var frontLocaleIdentifier: String
    public var backLocaleIdentifier: String
    public var correctCount: Int
    public var lastCorrectAt: Date

    public init(
        front: String,
        back: String,
        frontLocaleIdentifier: String,
        backLocaleIdentifier: String,
        correctCount: Int = 1,
        lastCorrectAt: Date = Date()
    ) {
        self.front = front
        self.back = back
        self.frontLocaleIdentifier = frontLocaleIdentifier
        self.backLocaleIdentifier = backLocaleIdentifier
        self.correctCount = correctCount
        self.lastCorrectAt = lastCorrectAt
    }

    public var identityKey: String {
        [frontLocaleIdentifier, front, backLocaleIdentifier, back]
            .map { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) }
            .joined(separator: "|")
    }

    public var spanish: String? {
        if frontLocaleIdentifier.hasPrefix("es") { return front }
        if backLocaleIdentifier.hasPrefix("es") { return back }
        return nil
    }

    public var english: String? {
        if frontLocaleIdentifier.hasPrefix("en") { return front }
        if backLocaleIdentifier.hasPrefix("en") { return back }
        return nil
    }
}
