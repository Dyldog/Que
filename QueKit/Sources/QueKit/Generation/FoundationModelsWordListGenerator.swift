#if canImport(FoundationModels)
import FoundationModels
#endif
import Foundation

/// Generates vocabulary on-device with Apple Foundation Models.
public struct FoundationModelsWordListGenerator: WordListGenerating {
    public init() {}

    public var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            if case .available = SystemLanguageModel.default.availability { return true }
        }
        #endif
        return false
    }

    public func generate(
        prompt: String,
        front: Language,
        back: Language,
        count: Int
    ) async throws -> [Word] {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            return try await generateOnDevice(
                prompt: prompt,
                front: front,
                back: back,
                count: count
            )
        }
        #endif
        throw WordListGenerationError.unavailable
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    private func generateOnDevice(
        prompt: String,
        front: Language,
        back: Language,
        count: Int
    ) async throws -> [Word] {
        guard case .available = SystemLanguageModel.default.availability else {
            throw WordListGenerationError.unavailable
        }

        let session = LanguageModelSession(
            instructions: "You generate concise, accurate vocabulary lists for language learners."
        )
        let request = """
        Generate exactly \(count) \(front.name) vocabulary words or short phrases about "\(prompt)", \
        each paired with its \(back.name) translation. Keep them distinct and avoid duplicates.
        """
        let response = try await session.respond(to: request, generating: GeneratedWordPairs.self)
        let words = response.content.pairs.map { Word(front: $0.term, back: $0.translation) }
        guard !words.isEmpty else { throw WordListGenerationError.empty }
        return words
    }
    #endif
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, *)
@Generable
private struct GeneratedWordPairs {
    @Guide(description: "The generated vocabulary pairs")
    var pairs: [GeneratedWordPair]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
private struct GeneratedWordPair {
    @Guide(description: "The word or short phrase in the language being studied")
    var term: String

    @Guide(description: "The translation in the learner's base language")
    var translation: String
}
#endif
