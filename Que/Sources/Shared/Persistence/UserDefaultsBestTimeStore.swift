import Foundation

/// A `BestTimeStore` backed by `UserDefaults`, so records survive between launches.
final class UserDefaultsBestTimeStore: BestTimeStore {
    private let defaults: UserDefaults
    private let fastestWordKey = "fastestWordTime"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var fastestWordTime: TimeInterval? {
        get { time(forKey: fastestWordKey) }
        set { setTime(newValue, forKey: fastestWordKey) }
    }

    private func time(forKey key: String) -> TimeInterval? {
        defaults.object(forKey: key) as? TimeInterval
    }

    private func setTime(_ time: TimeInterval?, forKey key: String) {
        if let time {
            defaults.set(time, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}
