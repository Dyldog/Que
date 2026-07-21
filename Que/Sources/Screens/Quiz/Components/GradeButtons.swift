import SwiftUI

/// The pair of large buttons for self-grading (fallback when speech is unavailable).
struct GradeButtons: View {
    let onGrade: (Bool) -> Void

    private let correctColor = ArcadePalette.neon
    private let wrongColor = Color(red: 1.0, green: 0.32, blue: 0.4)

    var body: some View {
        HStack(spacing: 16) {
            button(title: "MISS", systemImage: "xmark", color: wrongColor, correct: false)
            button(title: "GOT IT", systemImage: "checkmark", color: correctColor, correct: true)
        }
    }

    private func button(title: String, systemImage: String, color: Color, correct: Bool) -> some View {
        Button {
            onGrade(correct)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 38, weight: .black))
                Text(title)
                    .font(.system(size: 20, weight: .black, design: .monospaced))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(color, lineWidth: 2)
            )
            .foregroundStyle(color)
            .neonGlow(color, radius: 8)
        }
        .buttonStyle(.plain)
    }
}
