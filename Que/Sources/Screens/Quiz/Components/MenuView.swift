import SwiftUI

/// The landing screen: the app title, the fastest-word record, a shared wait-time
/// toggle, and the choice between endless Practice and a timed Sprint over a
/// chosen number of questions.
struct MenuView: View {
    let fastestWordTime: TimeInterval?
    /// Looks up the best time for a given sprint length, to show as a target.
    let bestSprintTime: (Int) -> TimeInterval?
    let onStartPractice: (Bool) -> Void
    let onStartSprint: (Int, Bool) -> Void

    private static let presetCounts = [10, 50, 100]

    @State private var selection: SprintSelection = .preset(10)
    @State private var customText = "25"
    @State private var waitsEnabled = true

    var body: some View {
        VStack(spacing: 24) {
            header
            waitsToggle
            practiceButton
            sprintCard
            Spacer()
        }
        .padding()
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("¿Qué?")
                .font(.system(size: 64, weight: .heavy))
            Text("Learn the Spanish interrogatives")
                .font(.headline)
                .foregroundStyle(.secondary)
            if let fastestWordTime {
                Label("Fastest word \(fastestWordTime.stopwatchText)", systemImage: "bolt.fill")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(.top, 32)
    }

    // MARK: - Shared wait-time toggle

    private var waitsToggle: some View {
        Toggle(isOn: $waitsEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Wait time between words")
                Text("Adaptive spacing, in both modes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Practice

    private var practiceButton: some View {
        Button {
            onStartPractice(waitsEnabled)
        } label: {
            VStack(spacing: 4) {
                Text("Practice")
                    .font(.title2.weight(.bold))
                Text("Endless")
                    .font(.subheadline)
                    .opacity(0.9)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
        }
        .buttonStyle(.borderedProminent)
    }

    // MARK: - Sprint

    private var sprintCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sprint")
                .font(.title2.weight(.bold))
            Text("Fastest time for a set number of questions")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            countPicker

            if case .custom = selection {
                customField
            }

            if let best = bestSprintTime(resolvedCount) {
                Label("Best for \(resolvedCount) · \(best.stopwatchText)", systemImage: "trophy.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                onStartSprint(resolvedCount, waitsEnabled)
            } label: {
                Text("Start Sprint · \(resolvedCount) questions")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.borderedProminent)
            .disabled(resolvedCount < 1)
        }
        .padding()
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
    }

    private var countPicker: some View {
        Picker("Questions", selection: $selection) {
            ForEach(Self.presetCounts, id: \.self) { count in
                Text("\(count)").tag(SprintSelection.preset(count))
            }
            Text("Custom").tag(SprintSelection.custom)
        }
        .pickerStyle(.segmented)
    }

    private var customField: some View {
        HStack {
            Text("Questions")
                .foregroundStyle(.secondary)
            Spacer()
            TextField("Count", text: $customText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.title3.weight(.semibold).monospacedDigit())
                .frame(width: 100)
        }
    }

    /// The number of questions the current selection resolves to.
    private var resolvedCount: Int {
        switch selection {
        case let .preset(count): count
        case .custom: max(1, Int(customText) ?? 0)
        }
    }
}

/// Which sprint length is selected in the menu.
private enum SprintSelection: Hashable {
    case preset(Int)
    case custom
}

#Preview {
    MenuView(
        fastestWordTime: 1.8,
        bestSprintTime: { $0 == 10 ? 42.5 : nil },
        onStartPractice: { _ in },
        onStartSprint: { _, _ in }
    )
}
