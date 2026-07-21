import Foundation

/// Stores the fastest single-word recall, shown in the header as a target to beat.
protocol BestTimeStore: AnyObject {
    var fastestWordTime: TimeInterval? { get set }
}
