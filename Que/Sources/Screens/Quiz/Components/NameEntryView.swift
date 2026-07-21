import SwiftUI

/// The arcade-style "enter your initials" screen shown after a sprint ends.
struct NameEntryView: View {
    let time: TimeInterval
    let title: String
    let config: SprintConfig
    let initialInitials: String
    let onSubmit: (String) -> Void

    @State private var letters: [Int]
    @State private var active = 0
    @State private var changeTick = 0
    @State private var titleGlow = false

    private let neon = ArcadePalette.neon
    private let hot = ArcadePalette.hot

    init(time: TimeInterval, title: String, config: SprintConfig, initialInitials: String, onSubmit: @escaping (String) -> Void) {
        self.time = time
        self.title = title
        self.config = config
        self.initialInitials = initialInitials
        self.onSubmit = onSubmit
        _letters = State(initialValue: Self.indices(from: initialInitials))
    }

    var body: some View {
        VStack(spacing: 24) {
            titleBanner
            scoreboard
            reels
            hint
            Spacer()
            enterButton
        }
        .padding(24)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sensoryFeedback(.selection, trigger: changeTick)
    }

    // MARK: - Title

    private var titleBanner: some View {
        VStack(spacing: 6) {
            Text("★ NEW SCORE ★")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundStyle(ArcadePalette.gold)
                .neonGlow(ArcadePalette.gold, radius: 8)
            Text("ENTER YOUR\nINITIALS")
                .font(.system(size: 34, weight: .black, design: .monospaced))
                .foregroundStyle(hot)
                .multilineTextAlignment(.center)
                .neonGlow(hot, radius: titleGlow ? 18 : 10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                titleGlow = true
            }
        }
    }

    // MARK: - Scoreboard

    private var scoreboard: some View {
        VStack(spacing: 4) {
            Text("YOUR TIME")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
            Text(time.stopwatchText)
                .font(.system(size: 44, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .neonGlow(neon, radius: 10)
            Text(configLabel)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(neon.opacity(0.85))
        }
    }

    private var configLabel: String {
        "\(title.uppercased()) · \(config.target) · \(config.waitsEnabled ? "WAITS ON" : "NO WAITS")"
    }

    // MARK: - Reels

    private var reels: some View {
        HStack(spacing: 14) {
            ForEach(0 ..< 3, id: \.self) { slot in
                InitialReel(
                    index: letters[slot],
                    isActive: active == slot,
                    onSteps: { step(slot, by: $0) },
                    onSelect: { active = slot }
                )
            }
        }
    }

    private var hint: some View {
        Text("SWIPE OR TAP THE ARROWS")
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.4))
    }

    // MARK: - Enter

    private var enterButton: some View {
        Button {
            onSubmit(currentInitials)
        } label: {
            Text("ENTER")
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(neon, in: Capsule())
                .neonGlow(neon, radius: 16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logic

    private func step(_ slot: Int, by delta: Int) {
        active = slot
        letters[slot] = (((letters[slot] + delta) % 26) + 26) % 26
        changeTick += 1
    }

    private var currentInitials: String {
        letters.map { String(UnicodeScalar(UInt8(65 + $0))) }.joined()
    }

    private static func indices(from initials: String) -> [Int] {
        var result = initials.uppercased().unicodeScalars.compactMap { scalar -> Int? in
            let value = Int(scalar.value)
            return (65 ... 90).contains(value) ? value - 65 : nil
        }
        while result.count < 3 { result.append(0) }
        return Array(result.prefix(3))
    }
}

#Preview {
    ZStack {
        PinballBackground()
        NameEntryView(
            time: 38.4,
            title: "Interrogatives",
            config: SprintConfig(listID: "x", target: 50, waitsEnabled: true),
            initialInitials: "DJE",
            onSubmit: { _ in }
        )
    }
}
