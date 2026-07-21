import SwiftUI

/// The landing screen, styled like a pinball backglass: the marquee title, the
/// chosen list, the sprint setup, and a High Scores button.
struct MenuView: View {
    let listName: String
    let generationError: String?
    let onChangeList: () -> Void
    let onStartSprint: (Int, Bool) -> Void
    let onOpenLeaderboard: () -> Void

    private static let presetCounts = [10, 50, 100]

    @State private var selection: SprintSelection = .preset(10)
    @State private var customText = "25"
    @State private var waitsEnabled = true
    @State private var marqueeGlow = false

    private let neon = ArcadePalette.neon
    private let hot = ArcadePalette.hot

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                marquee
                listButton
                setupPanel
                if let generationError {
                    Text(generationError.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(hot)
                        .multilineTextAlignment(.center)
                }
                leaderboardButton
            }
            .padding()
            .padding(.top, 20)
        }
    }

    private var marquee: some View {
        VStack(spacing: 10) {
            Text("¿QUÉ?")
                .font(.system(size: 68, weight: .black, design: .monospaced))
                .foregroundStyle(ArcadePalette.gold)
                .neonGlow(ArcadePalette.gold, radius: marqueeGlow ? 22 : 12)
            Text("VOCABULARY ARCADE")
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundStyle(hot)
                .tracking(3)
                .neonGlow(hot, radius: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                marqueeGlow = true
            }
        }
    }

    private var listButton: some View {
        Button(action: onChangeList) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LIST")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                    Text(listName.uppercased())
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundStyle(neon)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.black))
                    .foregroundStyle(neon)
            }
            .padding(18)
            .pinballPanel()
        }
        .buttonStyle(.plain)
    }

    private var setupPanel: some View {
        VStack(spacing: 18) {
            Text("SPRINT")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundStyle(neon)
                .frame(maxWidth: .infinity, alignment: .leading)

            countSelector
            if case .custom = selection { customField }
            waitToggle

            Button("START") { onStartSprint(resolvedCount, waitsEnabled) }
                .buttonStyle(.neon())
                .disabled(resolvedCount < 1)
        }
        .padding(20)
        .pinballPanel()
    }

    private var countSelector: some View {
        HStack(spacing: 8) {
            ForEach(Self.presetCounts, id: \.self) { count in
                countPill("\(count)", selected: selection == .preset(count)) { selection = .preset(count) }
            }
            countPill("CUSTOM", selected: selection == .custom) { selection = .custom }
        }
    }

    private func countPill(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundStyle(selected ? .black : neon)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background {
                    if selected { Capsule().fill(neon) }
                    else { Capsule().strokeBorder(neon.opacity(0.5), lineWidth: 1.5) }
                }
        }
        .buttonStyle(.plain)
    }

    private var customField: some View {
        HStack {
            Text("QUESTIONS")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            TextField("", text: $customText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(neon)
                .frame(width: 90)
        }
    }

    private var waitToggle: some View {
        Toggle(isOn: $waitsEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text("WAIT TIME")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                Text("Adaptive spacing between words")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .tint(neon)
    }

    private var leaderboardButton: some View {
        Button(action: onOpenLeaderboard) {
            Label("HIGH SCORES", systemImage: "trophy.fill")
        }
        .buttonStyle(.neon(hot, filled: false))
    }

    private var resolvedCount: Int {
        switch selection {
        case let .preset(count): count
        case .custom: max(1, Int(customText) ?? 0)
        }
    }
}

private enum SprintSelection: Hashable {
    case preset(Int)
    case custom
}

#Preview {
    ZStack {
        PinballBackground()
        MenuView(
            listName: "Interrogatives",
            generationError: nil,
            onChangeList: {},
            onStartSprint: { _, _ in },
            onOpenLeaderboard: {}
        )
    }
}
