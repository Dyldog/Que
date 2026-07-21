import Foundation

/// The word lists compiled into the app.
enum BundledLists {
    static let all: [WordList] = [interrogatives, numbers, colours, daysAndMonths, commonVerbs]

    static let interrogatives = WordList(
        id: "bundled.interrogatives",
        name: "Interrogatives",
        kind: .bundled,
        front: .spanish,
        back: .english,
        words: pairs([
            ("Cómo", "How?"),
            ("Dónde", "Where?"),
            ("Quién", "Who? (singular)"),
            ("Quiénes", "Who? (plural)"),
            ("Qué", "What?"),
            ("Cuál", "Which? (singular)"),
            ("Cuáles", "Which? (plural)"),
            ("Por qué", "Why?"),
            ("Cuánto", "How much?"),
            ("Cuántos", "How many? (male)"),
            ("Cuántas", "How many? (female)"),
            ("Cuándo", "When?"),
        ])
    )

    static let numbers = WordList(
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

    static let colours = WordList(
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

    static let daysAndMonths = WordList(
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

    static let commonVerbs = WordList(
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

    private static func pairs(_ raw: [(String, String)]) -> [Word] {
        raw.map { Word(front: $0.0, back: $0.1) }
    }
}
