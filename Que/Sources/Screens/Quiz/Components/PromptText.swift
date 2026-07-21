import SwiftUI

/// A word rendered in very large type, used for both the prompt and its translation.
struct PromptText: View {
    let text: String
    var emphasised: Bool = true

    var body: some View {
        Text(text)
            .font(.system(size: 60, weight: emphasised ? .bold : .regular))
            .foregroundStyle(emphasised ? Color.primary : Color.secondary)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            .lineLimit(3)
            .frame(maxWidth: .infinity)
    }
}
