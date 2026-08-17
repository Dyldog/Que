import Foundation

public enum WordListGenerationError: Error, Equatable, Sendable {
    case unavailable
    case empty
}

/// Generates vocabulary pairs for a prompt-based list.
public protocol WordListGenerating: Sendable {
    var isAvailable: Bool { get }

    func generate(
        prompt: String,
        front: Language,
        back: Language,
        count: Int
    ) async throws -> [Word]
}
