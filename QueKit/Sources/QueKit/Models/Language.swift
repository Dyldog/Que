import Foundation

/// A language used on one side of a vocabulary list.
public struct Language: Hashable, Codable, Sendable {
    public var name: String
    public var localeIdentifier: String

    public init(name: String, localeIdentifier: String) {
        self.name = name
        self.localeIdentifier = localeIdentifier
    }

    public var locale: Locale { Locale(identifier: localeIdentifier) }
    public var displayName: String { name }

    public static let english = Language(name: "English", localeIdentifier: "en-US")
    public static let spanish = Language(name: "Spanish", localeIdentifier: "es-ES")
    public static let french = Language(name: "French", localeIdentifier: "fr-FR")
    public static let german = Language(name: "German", localeIdentifier: "de-DE")
    public static let italian = Language(name: "Italian", localeIdentifier: "it-IT")
    public static let portuguese = Language(name: "Portuguese", localeIdentifier: "pt-PT")

    public static let presets: [Language] = [
        .english, .spanish, .french, .german, .italian, .portuguese,
    ]
}
