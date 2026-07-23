import SwiftUI

/// Shows all words in a list with option to start a sprint.
struct ListPreviewView: View {
    let list: WordList
    let onStart: (Int, Bool) -> Void
    let onBack: () -> Void

    @State private var target = 10
    @State private var waitsEnabled = true

    private let targets = [10, 20, 50, 100]

    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: list.name.uppercased(), onBack: onBack)
            
            ScrollView {
                VStack(spacing: 16) {
                    // List info
                    infoSection
                    
                    // Words
                    wordsSection
                    
                    // Start controls
                    startSection
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var infoSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: list.isGenerated ? "sparkles" : "text.book.closed.fill")
                    .foregroundStyle(list.isGenerated ? ArcadePalette.hot : ArcadePalette.neon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(list.front.name.uppercased() + " → " + list.back.name.uppercased())
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundStyle(ArcadePalette.gold)
                    
                    if list.isGenerated {
                        Text("GENERATED · \(list.prompt ?? "")")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(2)
                    } else {
                        Text("\(list.words.count) WORDS")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                Spacer()
            }
            .padding(14)
            .background(.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    private var wordsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WORDS")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
            
            if list.isGenerated {
                // Generated list - show the prompt and explain
                VStack(alignment: .leading, spacing: 8) {
                    Text("This list generates fresh words each round from the prompt:")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text(list.prompt ?? "—")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ArcadePalette.hot.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(ArcadePalette.hot.opacity(0.4), lineWidth: 1))
                    
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(ArcadePalette.hot)
                        Text("Words are generated on-device using Apple Intelligence when you start a sprint")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.top, 4)
                }
            } else {
                // Fixed list - show all words
                LazyVStack(spacing: 6) {
                    ForEach(Array(list.words.enumerated()), id: \.element.id) { index, word in
                        wordRow(index: index + 1, word: word)
                    }
                }
            }
        }
    }

    private func wordRow(index: Int, word: Word) -> some View {
        HStack(spacing: 12) {
            Text("\(index).")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))
                .frame(width: 32, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(word.front)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(ArcadePalette.neon)
                Text(word.back)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(12)
        .background(.white.opacity(0.02), in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var startSection: some View {
        VStack(spacing: 14) {
            // Target selector
            VStack(spacing: 8) {
                Text("QUESTIONS")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    ForEach(targets, id: \.self) { t in
                        Button {
                            target = t
                        } label: {
                            Text("\(t)")
                                .font(.system(size: 15, weight: .black, design: .monospaced))
                                .foregroundStyle(target == t ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .background(target == t ? ArcadePalette.neon : .white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(target == t ? ArcadePalette.neon.opacity(0.5) : .white.opacity(0.1), lineWidth: 1)
                        )
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Waits toggle
            Toggle(isOn: $waitsEnabled) {
                Text("ADAPTIVE WAIT")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .toggleStyle(.checkbox)
            .tint(ArcadePalette.neon)
            
            // Start button
            Button {
                onStart(target, waitsEnabled)
            } label: {
                Label("START SPRINT", systemImage: "play.fill")
                    .font(.system(size: 17, weight: .black, design: .monospaced))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.neon())
            .disabled(list.words.isEmpty)
            
            if list.words.isEmpty {
                Text(list.isGenerated ? "GENERATED LISTS HAVE NO WORDS UNTIL PLAYED" : "ADD WORDS IN EDIT MODE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(ArcadePalette.hot)
            }
        }
        .padding(16)
        .background(.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1.5)
        )
    }
}

/// Checkbox toggle style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            Button {
                configuration.isOn.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(configuration.isOn ? ArcadePalette.neon : .white.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(ArcadePalette.neon)
                    }
                }
            }
            .buttonStyle(.plain)
            
            configuration.label
        }
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkbox: CheckboxToggleStyle { CheckboxToggleStyle() }
}

#Preview {
    ListPreviewView(
        list: WordList(
            name: "Test List",
            kind: .custom,
            front: .spanish,
            back: .english,
            words: [
                Word(front: "Hola", back: "Hello"),
                Word(front: "Gracias", back: "Thanks"),
                Word(front: "Perro", back: "Dog"),
                Word(front: "Gato", back: "Cat"),
            ]
        ),
        onStart: { _, _ in },
        onBack: { }
    )
}