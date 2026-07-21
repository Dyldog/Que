import SwiftUI

/// A single spinning letter reel for the arcade name-entry screen. Shows the
/// current letter large with its neighbours fading above and below, and can be
/// changed with the chevrons or by dragging.
struct InitialReel: View {
    /// The selected letter as an index 0–25 (A–Z).
    let index: Int
    let isActive: Bool
    /// Advance the letter by a signed number of steps (+1 = next letter).
    let onSteps: (Int) -> Void
    let onSelect: () -> Void

    @State private var dragSteps = 0

    private let accent = ArcadePalette.neon

    var body: some View {
        VStack(spacing: 10) {
            chevron("chevron.up") { onSteps(-1) }
            window
            chevron("chevron.down") { onSteps(1) }
        }
    }

    private func chevron(_ name: String, action: @escaping () -> Void) -> some View {
        Button {
            onSelect()
            action()
        } label: {
            Image(systemName: name)
                .font(.title2.weight(.black))
                .foregroundStyle(isActive ? accent : accent.opacity(0.3))
                .frame(width: 44, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var window: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(.black.opacity(0.55))
            reel
                .frame(width: 96, height: 168)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .mask(fade)
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isActive ? accent : accent.opacity(0.3), lineWidth: isActive ? 3 : 1.5)
        }
        .frame(width: 108, height: 168)
        .modifier(ActiveGlow(isActive: isActive, color: accent))
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .gesture(scrub)
    }

    private var reel: some View {
        VStack(spacing: 4) {
            ForEach(-2 ... 2, id: \.self) { offset in
                letterView(offset: offset)
            }
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.85), value: index)
    }

    @ViewBuilder
    private func letterView(offset: Int) -> some View {
        let isCurrent = offset == 0
        let size: CGFloat = isCurrent ? 68 : 30
        let height: CGFloat = isCurrent ? 76 : 34
        Text(letter(index + offset))
            .font(.system(size: size, weight: .black, design: .monospaced))
            .foregroundStyle(isCurrent ? accent : accent.opacity(0.22))
            .neonGlow(isCurrent ? accent : .clear, radius: isCurrent ? 10 : 0)
            .frame(height: height)
    }

    private var fade: some View {
        LinearGradient(
            colors: [.clear, .black, .black, .clear],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var scrub: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                onSelect()
                let steps = Int((-value.translation.height / 46).rounded())
                if steps != dragSteps {
                    onSteps(steps - dragSteps)
                    dragSteps = steps
                }
            }
            .onEnded { _ in dragSteps = 0 }
    }

    private func letter(_ i: Int) -> String {
        let n = ((i % 26) + 26) % 26
        return String(UnicodeScalar(UInt8(65 + n)))
    }
}

/// A pulsing glow applied to the active reel.
private struct ActiveGlow: ViewModifier {
    let isActive: Bool
    let color: Color
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(pulse ? 0.9 : 0.4) : .clear, radius: isActive ? (pulse ? 22 : 12) : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
