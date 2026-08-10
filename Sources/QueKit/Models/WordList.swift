import Foundation

/// A named fixed vocabulary list or a reusable AI-generation prompt.
public struct WordList: Identifiable, Hashable, Codable, Sendable {
    public enum Kind: String, Codable, Hashable, Sendable {
        case bundled
        case custom
        case prompt
    }

    public let id: String
    public var name: String
    public var kind: Kind
    public var front: Language
    public var back: Language
    public var words: [Word]
    public var prompt: String?

    public init(
        id: String = UUID().uuidString,
        name: String,
        kind: Kind,
        front: Language,
        back: Language,
        words: [Word] = [],
        prompt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.front = front
        self.back = back
        self.words = words
        self.prompt = prompt
    }

    public var isGenerated: Bool { kind == .prompt }
}
