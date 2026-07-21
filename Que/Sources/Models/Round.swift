import Foundation

/// A single prompt: a word shown in one language, to be translated into the other.
struct Round: Equatable {
    let word: Word
    let promptLanguage: Language

    var promptText: String {
        text(for: promptLanguage)
    }

    var answerText: String {
        text(for: promptLanguage.opposite)
    }

    /// The language the user should answer in (and that speech recognition uses).
    var answerLanguage: Language {
        promptLanguage.opposite
    }

    private func text(for language: Language) -> String {
        switch language {
        case .spanish: word.spanish
        case .english: word.english
        }
    }

    /// A random word shown in a random language.
    static func random(from words: [Word] = WordBank.all) -> Round {
        Round(
            word: words.randomElement() ?? WordBank.all[0],
            promptLanguage: Bool.random() ? .spanish : .english
        )
    }
}
