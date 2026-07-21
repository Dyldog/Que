import Foundation

/// A single Spanish interrogative word paired with its English meaning.
struct Word: Identifiable, Equatable {
    let id: Int
    let spanish: String
    let english: String
}
