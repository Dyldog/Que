import Foundation

/// Imports Que's former UserDefaults-backed lists into QueKit exactly once.
public enum UserDefaultsWordListMigrator {
    public static let legacyKey = "userWordLists.v1"
    public static let migrationMarkerKey = "QueKit.didMigrateUserWordLists.v1"

    @discardableResult
    public static func migrateIfNeeded(
        defaults: UserDefaults = .standard,
        legacyKey: String = legacyKey,
        markerKey: String = migrationMarkerKey,
        to store: WordListStore
    ) throws -> Int {
        guard !defaults.bool(forKey: markerKey) else { return 0 }

        let lists: [WordList]
        if let data = defaults.data(forKey: legacyKey) {
            lists = try JSONDecoder().decode([WordList].self, from: data)
        } else {
            lists = []
        }

        for list in lists {
            try store.save(list)
        }
        defaults.set(true, forKey: markerKey)
        return lists.count
    }
}
