import SwiftUI

/// A glowing arcade button: filled neon for primary actions, outlined for secondary.
struct NeonButtonStyle: ButtonStyle {
    var color: Color = ArcadePalette.neon
    var filled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .black, design: .monospaced))
            .foregroundStyle(filled ? .black : color)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                if filled {
                    Capsule().fill(color)
                } else {
                    Capsule().strokeBorder(color, lineWidth: 2)
                }
            }
            .neonGlow(color, radius: filled ? 16 : 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == NeonButtonStyle {
    static func neon(_ color: Color = ArcadePalette.neon, filled: Bool = true) -> NeonButtonStyle {
        NeonButtonStyle(color: color, filled: filled)
    }
}
