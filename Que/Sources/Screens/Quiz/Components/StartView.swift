import SwiftUI

/// The idle landing screen with the app title and the Start button.
struct StartView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("¿Qué?")
                .font(.system(size: 72, weight: .heavy))

            Text("Learn the Spanish interrogatives")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: onStart) {
                Text("Start")
                    .font(.title.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
