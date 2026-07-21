import SwiftUI

/// A neon title bar with a back chevron, used by the full-screen sub-views.
struct TopBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(ArcadePalette.hot)
                .neonGlow(ArcadePalette.hot, radius: 10)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.black))
                        .foregroundStyle(ArcadePalette.neon)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}
