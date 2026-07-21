import Foundation

/// A non-persistent `WordListStore` for tests and SwiftUI previews.
final class InMemoryWordListStore: WordListStore {
    private var lists: [WordList]

    init(lists: [WordList] = []) {
        self.lists = lists
    }

    func userLists() -> [WordList] {
        lists
    }

    func save(_ list: WordList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
        } else {
            lists.append(list)
        }
    }

    func delete(id: String) {
        lists.removeAll { $0.id == id }
    }
}
