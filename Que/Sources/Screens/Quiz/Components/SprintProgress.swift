import Foundation

/// The live progress of a sprint, shown in the header.
struct SprintProgress: Equatable {
    let answered: Int
    let target: Int
    let totalElapsed: TimeInterval
}
