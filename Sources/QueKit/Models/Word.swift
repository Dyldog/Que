import Foundation

/// A vocabulary term and its translation.
public struct Word: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var front: String
    public var back: String

    public init(id: UUID = UUID(), front: String, back: String) {
        self.id = id
        self.front = front
        self.back = back
    }
}
