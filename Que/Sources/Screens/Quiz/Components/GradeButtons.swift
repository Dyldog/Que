import SwiftUI

/// The pair of very large buttons for self-grading a revealed word.
struct GradeButtons: View {
    let onGrade: (Bool) -> Void

    var body: some View {
        HStack(spacing: 16) {
            button(title: "Incorrect", systemImage: "xmark", tint: .red, correct: false)
            button(title: "Correct", systemImage: "checkmark", tint: .green, correct: true)
        }
    }

    private func button(title: String, systemImage: String, tint: Color, correct: Bool) -> some View {
        Button {
            onGrade(correct)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .bold))
                Text(title)
                    .font(.title2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 24))
            .foregroundStyle(tint)
        }
        .buttonStyle(.plain)
    }
}
