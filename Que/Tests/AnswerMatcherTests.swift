import Testing
@testable import Que

struct AnswerMatcherTests {

    @Test
    func matchesExactWord() {
        #expect(AnswerMatcher.matches(transcript: "qué", answer: "Qué"))
    }

    @Test
    func ignoresCaseAndAccents() {
        #expect(AnswerMatcher.matches(transcript: "QUE", answer: "Qué"))
        #expect(AnswerMatcher.matches(transcript: "donde", answer: "Dónde"))
    }

    @Test
    func ignoresParentheticalQualifiers() {
        #expect(AnswerMatcher.matches(transcript: "who", answer: "Who? (singular)"))
        #expect(AnswerMatcher.matches(transcript: "how many", answer: "How many? (male)"))
    }

    @Test
    func matchesMultiWordAnswer() {
        #expect(AnswerMatcher.matches(transcript: "por qué", answer: "Por qué"))
    }

    @Test
    func acceptsAnswerWithinALongerPhrase() {
        #expect(AnswerMatcher.matches(transcript: "I think it's dónde", answer: "Dónde"))
    }

    @Test
    func rejectsAWrongAnswer() {
        #expect(!AnswerMatcher.matches(transcript: "what", answer: "Qué"))
    }

    @Test
    func distinguishesGenderedForms() {
        #expect(!AnswerMatcher.matches(transcript: "cuántas", answer: "Cuántos"))
        #expect(AnswerMatcher.matches(transcript: "cuántos", answer: "Cuántos"))
    }

    @Test
    func rejectsEmptyTranscript() {
        #expect(!AnswerMatcher.matches(transcript: "", answer: "Qué"))
    }
}
