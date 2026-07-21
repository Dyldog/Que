import Foundation

/// A single prompt: a word shown on one side, to be translated to the other.
struct Round: Equatable {
    let word: Word
    /// Whether the `front` side is shown (and the `back` must be answered).
    let promptIsFront: Bool
    let frontLanguage: Language
    let backLanguage: Language

    var promptText: String {
        promptIsFront ? word.front : word.back
    }

    var answerText: String {
        promptIsFront ? word.back : word.front
    }

    /// The language the user should answer in (and that speech recognition uses).
    var answerLanguage: Language {
        promptIsFront ? backLanguage : frontLanguage
    }

    /// A random word from the list, shown in a random direction.
    static func random(from words: [Word], front: Language, back: Language) -> Round? {
        guard let word = words.randomElement() else { return nil }
        return Round(
            word: word,
            promptIsFront: Bool.random(),
            frontLanguage: front,
            backLanguage: back
        )
    }
}
