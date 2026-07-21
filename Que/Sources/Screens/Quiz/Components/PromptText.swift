import SwiftUI

/// A word rendered in very large arcade type, used for the prompt and its translation.
struct PromptText: View {
    let text: String
    var emphasised: Bool = true

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 58, weight: .black, design: .rounded))
            .foregroundStyle(emphasised ? Color.white : ArcadePalette.neon.opacity(0.7))
            .neonGlow(emphasised ? ArcadePalette.neon : .clear, radius: emphasised ? 14 : 0)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            .lineLimit(3)
            .frame(maxWidth: .infinity)
    }
}
