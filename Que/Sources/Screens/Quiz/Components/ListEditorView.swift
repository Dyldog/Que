import SwiftUI

/// Builds or edits a user list — either a fixed set of words or a generation prompt.
struct ListEditorView: View {
    let list: WordList
    let canDelete: Bool
    let generationAvailable: Bool
    let onSave: (WordList) -> Void
    let onDelete: (WordList) -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var front: Language
    @State private var back: Language
    @State private var words: [Word]
    @State private var prompt: String

    private let neon = ArcadePalette.neon

    init(
        list: WordList,
        canDelete: Bool,
        generationAvailable: Bool,
        onSave: @escaping (WordList) -> Void,
        onDelete: @escaping (WordList) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.list = list
        self.canDelete = canDelete
        self.generationAvailable = generationAvailable
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        _name = State(initialValue: list.name)
        _front = State(initialValue: list.front)
        _back = State(initialValue: list.back)
        _words = State(initialValue: list.words.isEmpty ? [Word(front: "", back: "")] : list.words)
        _prompt = State(initialValue: list.prompt ?? "")
    }

    private var isGenerated: Bool { list.kind == .prompt }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: isGenerated ? "GENERATED LIST" : "CUSTOM LIST", onBack: onCancel)
            ScrollView {
                VStack(spacing: 18) {
                    nameField
                    languageRow
                    if isGenerated { promptEditor } else { wordsEditor }
                    saveButton
                    if canDelete { deleteButton }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Fields

    private var nameField: some View {
        labeledField("NAME") {
            TextField("", text: $name, prompt: fieldPrompt("List name"))
                .textInputAutocapitalization(.words)
                .arcadeField()
        }
    }

    private var languageRow: some View {
        HStack(spacing: 12) {
            languageMenu("FRONT", selection: $front)
            languageMenu("BACK", selection: $back)
        }
    }

    private func languageMenu(_ label: String, selection: Binding<Language>) -> some View {
        labeledField(label) {
            Menu {
                ForEach(Language.presets, id: \.self) { language in
                    Button(language.name) { selection.wrappedValue = language }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue.name.uppercased())
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .foregroundStyle(neon)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down").foregroundStyle(neon.opacity(0.7))
                }
                .arcadeField()
            }
        }
    }

    private var promptEditor: some View {
        labeledField("PROMPT") {
            VStack(alignment: .leading, spacing: 8) {
                TextField("", text: $prompt, prompt: fieldPrompt("e.g. French kitchen vocabulary"), axis: .vertical)
                    .lineLimit(3 ... 6)
                    .arcadeField()
                Text("Words are generated fresh each round and never saved.")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.45))
                if !generationAvailable {
                    Text("GENERATION NEEDS APPLE INTELLIGENCE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcadePalette.hot)
                }
            }
        }
    }

    private var wordsEditor: some View {
        labeledField("WORDS") {
            VStack(spacing: 10) {
                ForEach($words) { $word in
                    wordRow($word)
                }
                Button {
                    words.append(Word(front: "", back: ""))
                } label: {
                    Label("ADD WORD", systemImage: "plus")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundStyle(neon)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
    }

    private func wordRow(_ word: Binding<Word>) -> some View {
        HStack(spacing: 8) {
            TextField("", text: word.front, prompt: fieldPrompt(front.name)).arcadeField()
            TextField("", text: word.back, prompt: fieldPrompt(back.name)).arcadeField()
            Button {
                words.removeAll { $0.id == word.wrappedValue.id }
            } label: {
                Image(systemName: "minus.circle.fill").foregroundStyle(ArcadePalette.hot.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private var saveButton: some View {
        Button("SAVE") { onSave(buildList()) }
            .buttonStyle(.neon())
            .disabled(!isValid)
            .padding(.top, 4)
    }

    private var deleteButton: some View {
        Button("DELETE LIST") { onDelete(list) }
            .buttonStyle(.neon(ArcadePalette.hot, filled: false))
    }

    private var cleanedWords: [Word] {
        words.filter {
            !$0.front.trimmingCharacters(in: .whitespaces).isEmpty &&
            !$0.back.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if isGenerated {
            return !prompt.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return !cleanedWords.isEmpty
    }

    private func buildList() -> WordList {
        var result = list
        result.name = name.trimmingCharacters(in: .whitespaces)
        result.front = front
        result.back = back
        if isGenerated {
            result.prompt = prompt.trimmingCharacters(in: .whitespaces)
            result.words = []
        } else {
            result.prompt = nil
            result.words = cleanedWords
        }
        return result
    }

    // MARK: - Styling helpers

    private func labeledField(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fieldPrompt(_ text: String) -> Text {
        Text(text).foregroundColor(.white.opacity(0.3))
    }
}

private extension View {
    /// A dark arcade input-field background.
    func arcadeField() -> some View {
        font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .tint(ArcadePalette.neon)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(ArcadePalette.neon.opacity(0.3), lineWidth: 1))
    }
}
