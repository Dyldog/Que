import Foundation

/// A single vocabulary pair: the word in the studied language (`front`) and its
/// meaning in the base language (`back`).
struct Word: Identifiable, Hashable, Codable {
    var id: UUID
    var front: String
    var back: String

    init(id: UUID = UUID(), front: String, back: String) {
        self.id = id
        self.front = front
        self.back = back
    }
}
