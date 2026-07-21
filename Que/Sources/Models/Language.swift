import Foundation

/// A language a word can be shown or spoken in, with the locale used for speech
/// recognition.
struct Language: Hashable, Codable {
    var name: String
    var localeIdentifier: String

    var locale: Locale { Locale(identifier: localeIdentifier) }
    var displayName: String { name }

    static let english = Language(name: "English", localeIdentifier: "en-US")
    static let spanish = Language(name: "Spanish", localeIdentifier: "es-ES")
    static let french = Language(name: "French", localeIdentifier: "fr-FR")
    static let german = Language(name: "German", localeIdentifier: "de-DE")
    static let italian = Language(name: "Italian", localeIdentifier: "it-IT")
    static let portuguese = Language(name: "Portuguese", localeIdentifier: "pt-PT")

    /// The languages offered when building a list.
    static let presets: [Language] = [.english, .spanish, .french, .german, .italian, .portuguese]
}
