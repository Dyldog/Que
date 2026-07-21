import Foundation

/// Stores the personal-best times the app shows as targets to beat:
/// the fastest single-word recall, and the best sprint time per question count.
protocol BestTimeStore: AnyObject {
    var fastestWordTime: TimeInterval? { get set }
    func bestSprintTime(target: Int) -> TimeInterval?
    func setBestSprintTime(_ time: TimeInterval, target: Int)
}
