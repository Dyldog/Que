import Foundation

/// The language a word can be shown in.
enum Language {
    case spanish
    case english

    var opposite: Language {
        self == .spanish ? .english : .spanish
    }

    /// The locale used for speech recognition of this language.
    var locale: Locale {
        switch self {
        case .spanish: Locale(identifier: "es-ES")
        case .english: Locale(identifier: "en-US")
        }
    }

    var displayName: String {
        switch self {
        case .spanish: "Spanish"
        case .english: "English"
        }
    }
}
