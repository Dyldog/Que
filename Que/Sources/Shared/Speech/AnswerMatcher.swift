import Foundation

/// Decides whether something the user said counts as the expected translation.
///
/// Matching is deliberately lenient: it ignores case, accents, punctuation and
/// parenthetical qualifiers (e.g. the "(singular)" in "Who? (singular)"), and it
/// accepts the answer appearing anywhere within a longer spoken phrase.
enum AnswerMatcher {

    static func matches(transcript: String, answer: String) -> Bool {
        let spoken = tokens(in: transcript)
        let expected = tokens(in: stripParentheticals(answer))
        guard !expected.isEmpty else { return false }
        return contains(spoken, subsequence: expected)
    }

    /// Removes any "(...)" qualifier from an answer.
    private static func stripParentheticals(_ text: String) -> String {
        text.replacingOccurrences(of: "\\([^)]*\\)", with: " ", options: .regularExpression)
    }

    /// Lowercased, accent-stripped, alphanumeric-only words.
    private static func tokens(in text: String) -> [String] {
        let folded = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        let separated = folded.unicodeScalars.map { scalar in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : " "
        }
        return String(separated).split(separator: " ").map(String.init)
    }

    /// Whether `needle` appears as a run of consecutive words within `haystack`.
    private static func contains(_ haystack: [String], subsequence needle: [String]) -> Bool {
        guard needle.count <= haystack.count else { return false }
        for start in 0...(haystack.count - needle.count) where Array(haystack[start ..< start + needle.count]) == needle {
            return true
        }
        return false
    }
}
