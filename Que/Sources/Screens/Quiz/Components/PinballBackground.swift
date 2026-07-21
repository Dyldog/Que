import SwiftUI

/// The dark, neon-lit backglass look used behind every screen.
struct PinballBackground: View {
    var body: some View {
        ZStack {
            ArcadePalette.background
            RadialGradient(colors: [ArcadePalette.neon.opacity(0.16), .clear], center: .top, startRadius: 8, endRadius: 460)
            RadialGradient(colors: [ArcadePalette.hot.opacity(0.14), .clear], center: .bottomLeading, startRadius: 8, endRadius: 440)
            RadialGradient(colors: [ArcadePalette.gold.opacity(0.10), .clear], center: .bottomTrailing, startRadius: 8, endRadius: 420)
            grid
            vignette
        }
        .ignoresSafeArea()
    }

    /// A faint playfield grid.
    private var grid: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 44
            Path { path in
                var x: CGFloat = 0
                while x <= proxy.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    x += spacing
                }
                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(ArcadePalette.neon.opacity(0.05), lineWidth: 1)
        }
    }

    private var vignette: some View {
        RadialGradient(
            colors: [.clear, .black.opacity(0.55)],
            center: .center,
            startRadius: 220,
            endRadius: 640
        )
    }
}
