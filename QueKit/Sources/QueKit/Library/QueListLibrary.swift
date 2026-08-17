import Foundation

/// Vocabulary lists distributed with QueKit.
public enum QueListLibrary {
    public static let builtInLists: [WordList] = [
        interrogatives,
        numbers,
        colours,
        daysAndMonths,
        commonVerbs,
    ]

    /// Dylan's larger Spanish lists that were previously JSON resources in Que.
    public static let personalBundledLists: [WordList] = loadPersonalBundledLists()

    public static let allBundledLists: [WordList] = builtInLists + personalBundledLists

    public static let interrogatives = WordList(
        id: "bundled.interrogatives",
        name: "Interrogatives",
        kind: .bundled,
        front: .spanish,
        back: .english,
        words: pairs([
            ("Cómo", "How?"), ("Dónde", "Where?"), ("Quién", "Who? (singular)"),
            ("Quiénes", "Who? (plural)"), ("Qué", "What?"), ("Cuál", "Which? (singular)"),
            ("Cuáles", "Which? (plural)"), ("Por qué", "Why?"), ("Cuánto", "How much?"),
            ("Cuántos", "How many? (male)"), ("Cuántas", "How many? (female)"),
            ("Cuándo", "When?"),
        ])
    )

    public static let numbers = WordList(
        id: "bundled.numbers",
        name: "Numbers 1–20",
        kind: .bundled,
        front: .spanish,
        back: .english,
        words: pairs([
            ("Uno", "One"), ("Dos", "Two"), ("Tres", "Three"), ("Cuatro", "Four"),
            ("Cinco", "Five"), ("Seis", "Six"), ("Siete", "Seven"), ("Ocho", "Eight"),
            ("Nueve", "Nine"), ("Diez", "Ten"), ("Once", "Eleven"), ("Doce", "Twelve"),
            ("Trece", "Thirteen"), ("Catorce", "Fourteen"), ("Quince", "Fifteen"),
            ("Dieciséis", "Sixteen"), ("Diecisiete", "Seventeen"), ("Dieciocho", "Eighteen"),
            ("Diecinueve", "Nineteen"), ("Veinte", "Twenty"),
        ])
    )

    public static let colours = WordList(
        id: "bundled.colours",
        name: "Colours",
        kind: .bundled,
        front: .spanish,
        back: .english,
        words: pairs([
            ("Rojo", "Red"), ("Azul", "Blue"), ("Verde", "Green"), ("Amarillo", "Yellow"),
            ("Negro", "Black"), ("Blanco", "White"), ("Naranja", "Orange"), ("Morado", "Purple"),
            ("Rosa", "Pink"), ("Gris", "Grey"), ("Marrón", "Brown"),
        ])
    )

    public static let daysAndMonths = WordList(
        id: "bundled.days_months",
        name: "Days & Months",
        kind: .bundled,
        front: .spanish,
        back: .english,
        words: pairs([
            ("Lunes", "Monday"), ("Martes", "Tuesday"), ("Miércoles", "Wednesday"),
            ("Jueves", "Thursday"), ("Viernes", "Friday"), ("Sábado", "Saturday"),
            ("Domingo", "Sunday"), ("Enero", "January"), ("Febrero", "February"),
            ("Marzo", "March"), ("Abril", "April"), ("Mayo", "May"), ("Junio", "June"),
            ("Julio", "July"), ("Agosto", "August"), ("Septiembre", "September"),
            ("Octubre", "October"), ("Noviembre", "November"), ("Diciembre", "December"),
        ])
    )

    public static let commonVerbs = WordList(
        id: "bundled.common_verbs",
        name: "Common Verbs",
        kind: .bundled,
        front: .spanish,
        back: .english,
        words: pairs([
            ("Ser", "To be"), ("Estar", "To be (state)"), ("Tener", "To have"),
            ("Hacer", "To do / make"), ("Ir", "To go"), ("Poder", "To be able"),
            ("Querer", "To want"), ("Decir", "To say"), ("Ver", "To see"),
            ("Dar", "To give"), ("Saber", "To know"), ("Comer", "To eat"),
            ("Beber", "To drink"), ("Hablar", "To speak"), ("Vivir", "To live"),
        ])
    )

    private struct BundledListDocument: Decodable {
        let name: String
        let kind: WordList.Kind
        let front: String
        let back: String
        let words: [BundledWord]
    }

    private struct BundledWord: Decodable {
        let front: String
        let back: String
    }

    private static func loadPersonalBundledLists() -> [WordList] {
        let names = ["DylansKnownSpanishVerbForms", "SpanishVocabulary"]
        return names.compactMap { name in
            guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let document = try? JSONDecoder().decode(BundledListDocument.self, from: data) else {
                return nil
            }
            let front = Language.presets.first { $0.name == document.front } ?? .spanish
            let back = Language.presets.first { $0.name == document.back } ?? .english
            return WordList(
                id: "bundled.json.\(name)",
                name: document.name,
                kind: .bundled,
                front: front,
                back: back,
                words: document.words.map { Word(front: $0.front, back: $0.back) }
            )
        }
    }

    private static func pairs(_ raw: [(String, String)]) -> [Word] {
        raw.map { Word(front: $0.0, back: $0.1) }
    }
}
