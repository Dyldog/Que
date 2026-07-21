import SwiftUI

/// Chooses which list to play: the bundled lists, the user's own lists (fixed or
/// generated prompts), or the option to create a new one.
struct ListPickerView: View {
    let bundled: [WordList]
    let userLists: [WordList]
    let selectedID: String
    let generationAvailable: Bool
    let onSelect: (WordList) -> Void
    let onEdit: (WordList) -> Void
    let onDelete: (WordList) -> Void
    let onCreate: (WordList.Kind) -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: "CHOOSE LIST", onBack: onBack)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    section("BUNDLED", lists: bundled, editable: false)
                    section("YOUR LISTS", lists: userLists, editable: true)
                    createButtons
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func section(_ title: String, lists: [WordList], editable: Bool) -> some View {
        if !lists.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(ArcadePalette.gold)
                ForEach(lists) { list in
                    row(list, editable: editable)
                }
            }
        }
    }

    private func row(_ list: WordList, editable: Bool) -> some View {
        let selected = list.id == selectedID
        let color = selected ? ArcadePalette.neon : Color.white
        return HStack(spacing: 12) {
            Button {
                onSelect(list)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: list.isGenerated ? "sparkles" : "text.book.closed.fill")
                        .foregroundStyle(list.isGenerated ? ArcadePalette.hot : ArcadePalette.neon)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(list.name.isEmpty ? "UNTITLED" : list.name.uppercased())
                            .font(.system(size: 17, weight: .black, design: .monospaced))
                            .foregroundStyle(color)
                            .lineLimit(1)
                        Text(subtitle(for: list))
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Spacer()
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(ArcadePalette.neon)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if editable {
                Button { onEdit(list) } label: {
                    Image(systemName: "pencil").foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
                Button { onDelete(list) } label: {
                    Image(systemName: "trash").foregroundStyle(ArcadePalette.hot.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(selected ? ArcadePalette.neon.opacity(0.12) : .white.opacity(0.03), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(selected ? ArcadePalette.neon.opacity(0.7) : .white.opacity(0.08), lineWidth: 1.5)
        )
    }

    private var createButtons: some View {
        VStack(spacing: 12) {
            Button { onCreate(.custom) } label: {
                Label("NEW LIST", systemImage: "plus")
            }
            .buttonStyle(.neon())

            Button { onCreate(.prompt) } label: {
                Label("NEW GENERATED LIST", systemImage: "sparkles")
            }
            .buttonStyle(.neon(ArcadePalette.hot, filled: false))

            if !generationAvailable {
                Text("GENERATION NEEDS APPLE INTELLIGENCE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.top, 4)
    }

    private func subtitle(for list: WordList) -> String {
        let languages = "\(list.front.name.uppercased())→\(list.back.name.uppercased())"
        if list.isGenerated {
            return "GENERATED · \(languages)"
        }
        return "\(list.words.count) WORDS · \(languages)"
    }
}
