import SwiftUI

/// Shared neon colours for the arcade-styled name-entry and leaderboard screens.
enum ArcadePalette {
    static let neon = Color(red: 0.36, green: 1.0, blue: 0.86)   // cyan-green
    static let hot = Color(red: 1.0, green: 0.30, blue: 0.72)    // hot pink
    static let gold = Color(red: 1.0, green: 0.82, blue: 0.25)

    static let background = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.02, blue: 0.10),
            Color(red: 0.10, green: 0.03, blue: 0.18),
            .black,
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension View {
    /// A neon glow around text or shapes.
    func neonGlow(_ color: Color, radius: CGFloat = 12) -> some View {
        shadow(color: color.opacity(0.9), radius: radius)
            .shadow(color: color.opacity(0.4), radius: radius * 2)
    }
}
