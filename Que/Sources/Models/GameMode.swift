import Foundation

/// The two ways to play: endless adaptive practice, or a timed sprint over a
/// fixed number of questions. Either mode may enforce the adaptive wait between
/// words.
enum GameMode: Equatable {
    case practice(waitsEnabled: Bool)
    case sprint(target: Int, waitsEnabled: Bool)

    var isSprint: Bool {
        if case .sprint = self { true } else { false }
    }

    /// Whether the adaptive wait between words is enforced.
    var usesWaits: Bool {
        switch self {
        case let .practice(waitsEnabled): waitsEnabled
        case let .sprint(_, waitsEnabled): waitsEnabled
        }
    }

    /// The number of questions in a sprint, or `nil` for practice.
    var target: Int? {
        if case let .sprint(target, _) = self { target } else { nil }
    }
}
