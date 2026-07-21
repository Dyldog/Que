import SwiftUI

/// Shown while a prompt list's words are being generated at the start of a round.
struct GeneratingView: View {
    let listName: String
    let onCancel: () -> Void

    @State private var spin = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 64, weight: .black))
                .foregroundStyle(ArcadePalette.hot)
                .neonGlow(ArcadePalette.hot, radius: 16)
                .rotationEffect(.degrees(spin ? 360 : 0))
                .animation(.linear(duration: 2.2).repeatForever(autoreverses: false), value: spin)

            VStack(spacing: 8) {
                Text("GENERATING")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundStyle(ArcadePalette.neon)
                    .tracking(4)
                    .neonGlow(ArcadePalette.neon, radius: 8)
                Text(listName.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button("CANCEL", action: onCancel)
                .buttonStyle(.neon(ArcadePalette.hot, filled: false))
                .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { spin = true }
    }
}
