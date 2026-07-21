import Foundation

enum WordListGenerationError: Error {
    case unavailable
    case empty
}

/// Generates the words for a prompt-based list at the start of a round.
protocol WordListGenerating {
    /// Whether on-device generation is available on this device.
    var isAvailable: Bool { get }

    /// Generates up to `count` word pairs for `prompt`, in the given languages.
    func generate(prompt: String, front: Language, back: Language, count: Int) async throws -> [Word]
}
