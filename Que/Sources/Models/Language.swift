import Foundation

/// The language a word can be shown in.
enum Language {
    case spanish
    case english

    var opposite: Language {
        self == .spanish ? .english : .spanish
    }
}
