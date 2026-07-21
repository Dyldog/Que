import Foundation

/// A named set of words to practise. A list is either a fixed set of `words`
/// (bundled with the app or built by the user), or a `prompt` whose words are
/// generated fresh at the start of each round and never saved.
struct WordList: Identifiable, Hashable, Codable {
    enum Kind: String, Codable, Hashable {
        case bundled
        case custom
        case prompt
    }

    let id: String
    var name: String
    var kind: Kind
    var front: Language
    var back: Language
    /// The fixed words for `.bundled` / `.custom` lists.
    var words: [Word]
    /// The generation prompt for `.prompt` lists.
    var prompt: String?

    init(
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

    /// Whether the list's words are produced by generation at round start.
    var isGenerated: Bool { kind == .prompt }
}
