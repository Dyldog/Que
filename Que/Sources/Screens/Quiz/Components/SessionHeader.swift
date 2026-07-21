import Foundation

/// Everything shown at the top of the screen while playing: the current word's
/// stopwatch, the fastest-word record to beat, and (in a sprint) live progress.
struct SessionHeader {
    let elapsed: TimeInterval
    let fastestWordTime: TimeInterval?
    let sprint: SprintProgress?
}
