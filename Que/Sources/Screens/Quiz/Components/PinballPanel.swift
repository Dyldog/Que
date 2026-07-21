import SwiftUI

/// A dark translucent panel with a neon border, used to frame content like a
/// pinball backglass insert.
struct PinballPanel: ViewModifier {
    var color: Color = ArcadePalette.neon

    func body(content: Content) -> some View {
        content
            .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(color.opacity(0.55), lineWidth: 1.5)
            )
    }
}

extension View {
    func pinballPanel(_ color: Color = ArcadePalette.neon) -> some View {
        modifier(PinballPanel(color: color))
    }
}
