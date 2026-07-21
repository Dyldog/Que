import Foundation

/// The fixed set of Spanish interrogative words to practise.
enum WordBank {
    static let all: [Word] = [
        Word(id: 0, spanish: "Cómo", english: "How?"),
        Word(id: 1, spanish: "Dónde", english: "Where?"),
        Word(id: 2, spanish: "Quién", english: "Who? (singular)"),
        Word(id: 3, spanish: "Quiénes", english: "Who? (plural)"),
        Word(id: 4, spanish: "Qué", english: "What?"),
        Word(id: 5, spanish: "Cuál", english: "Which? (singular)"),
        Word(id: 6, spanish: "Cuáles", english: "Which? (plural)"),
        Word(id: 7, spanish: "Por qué", english: "Why?"),
        Word(id: 8, spanish: "Cuánto", english: "How much?"),
        Word(id: 9, spanish: "Cuántos", english: "How many? (male)"),
        Word(id: 10, spanish: "Cuántas", english: "How many? (female)"),
        Word(id: 11, spanish: "Cuándo", english: "When?"),
    ]
}
