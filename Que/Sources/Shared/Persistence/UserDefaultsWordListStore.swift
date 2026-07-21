import Foundation

/// A `WordListStore` backed by `UserDefaults` (JSON).
final class UserDefaultsWordListStore: WordListStore {
    private let defaults: UserDefaults
    private let key = "userWordLists.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func userLists() -> [WordList] {
        load()
    }

    func save(_ list: WordList) {
        var lists = load()
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
        } else {
            lists.append(list)
        }
        persist(lists)
    }

    func delete(id: String) {
        persist(load().filter { $0.id != id })
    }

    private func load() -> [WordList] {
        guard let raw = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WordList].self, from: raw) else {
            return []
        }
        return decoded
    }

    private func persist(_ lists: [WordList]) {
        guard let encoded = try? JSONEncoder().encode(lists) else { return }
        defaults.set(encoded, forKey: key)
    }
}
