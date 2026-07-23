import Foundation

/// Loads word lists from JSON files bundled with the app.
final class BundledJSONWordListStore: WordListStore {
    func userLists() -> [WordList] {
        var lists: [WordList] = []
        
        // Find all JSON files in the bundle
        let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        
        for url in urls {
            guard let data = try? Data(contentsOf: url),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let name = json["name"] as? String,
                  let kindStr = json["kind"] as? String,
                  let kind = WordList.Kind(rawValue: kindStr),
                  let frontName = json["front"] as? String,
                  let backName = json["back"] as? String,
                  let wordsArray = json["words"] as? [[String: String]] else {
                continue
            }
            
            // Find the language presets
            let front = Language.presets.first { $0.name == frontName } ?? Language.spanish
            let back = Language.presets.first { $0.name == backName } ?? Language.english
            
            let words = wordsArray.compactMap { dict -> Word? in
                guard let front = dict["front"], let back = dict["back"] else { return nil }
                return Word(front: front, back: back)
            }
            
            let list = WordList(
                id: "bundled.json.\(url.deletingPathExtension().lastPathComponent)",
                name: name,
                kind: kind,
                front: front,
                back: back,
                words: words
            )
            
            lists.append(list)
        }
        
        return lists
    }
    
    func save(_ list: WordList) {
        // Bundled lists are read-only
    }
    
    func delete(id: String) {
        // Bundled lists are read-only
    }
}