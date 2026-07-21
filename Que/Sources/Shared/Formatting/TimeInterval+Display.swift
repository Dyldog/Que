import Foundation

extension TimeInterval {
    /// A stopwatch-style string: seconds with one decimal below a minute
    /// (e.g. `4.3`), and `m:ss.d` at a minute or more (e.g. `1:07.4`).
    var stopwatchText: String {
        let clamped = Swift.max(0, self)
        let totalTenths = Int((clamped * 10).rounded())
        let tenths = totalTenths % 10
        let totalSeconds = totalTenths / 10
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60

        if minutes > 0 {
            return String(format: "%d:%02d.%d", minutes, seconds, tenths)
        } else {
            return String(format: "%d.%d", seconds, tenths)
        }
    }
}
