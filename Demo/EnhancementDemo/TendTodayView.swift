import HumanTouch
import SwiftUI

// MARK: - Sample data

struct Plant: Identifiable {
    let id = UUID()
    let name: String
    let species: String
    let symbol: String
    let note: String
    let status: Status

    enum Status { case thirsty, happy, checkLight }

    static let samples: [Plant] = [
        Plant(name: "Fern", species: "Boston fern", symbol: "leaf.fill", note: "Soil dry 2 cm down", status: .thirsty),
        Plant(name: "Basil", species: "Sweet basil", symbol: "camera.macro", note: "Pinch the flower buds", status: .thirsty),
        Plant(name: "Monty", species: "Monstera deliciosa", symbol: "tree.fill", note: "New leaf unfurling", status: .happy),
        Plant(name: "Ivy", species: "Pothos", symbol: "laurel.leading", note: "Leaves turning pale", status: .checkLight),
    ]
}

enum AskPhase: Equatable {
    case idle, solving, composing, answered
}

// MARK: - Today

/// "Tend", a small plant-care journal. Everything here reads the direction
/// set by `.humanTouch(_:)` on the tab, so each brief re-dresses the same screen.
struct TendTodayView: View {
    @Environment(\.touchDirection) private var direction
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var phase: AskPhase
    @State private var showOnboarding = true

    init(initialAsk: AskPhase = .idle) {
        _phase = State(initialValue: initialAsk)
    }

    private var thirsty: Int { Plant.samples.filter { $0.status == .thirsty }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                layout
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: sizeClass == .regular ? 1100 : 640)
                    .frame(maxWidth: .infinity)
                .touchAnimation(value: phase)
                .touchAnimation(value: showOnboarding)
            }
            .themedBackground()
            .navigationTitle("Tend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(direction.theme.dynamicColor(.background), for: .navigationBar)
        }
    }

    /// One column on compact widths; on wide screens (iPad, an open Duo) the
    /// greeting, helper and onboarding sit beside the plant list.
    @ViewBuilder private var layout: some View {
        if sizeClass == .regular {
            HStack(alignment: .top, spacing: 28) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    keyNumber
                    helper
                    if showOnboarding { onboarding }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                plants
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            VStack(alignment: .leading, spacing: 20) {
                header
                keyNumber
                helper
                plants
                if showOnboarding { onboarding }
            }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Monday, 28 September")
                .themedFont(.caption)
                .themedForeground(.textMuted)
            Text("Good evening, Maya")
                .themedFont(.display)
                .themedForeground(.text)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var keyNumber: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(thirsty)")
                .themedFont(.display)
                .touchEmphasis()
            Text("plants are thirsty today")
                .themedFont(.title)
                .themedForeground(.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Helper

    private var helper: some View {
        TouchCard {
            HStack(alignment: .center, spacing: 12) {
                assistantFace
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ask the helper")
                        .themedFont(.headline)
                    Text("Why is Ivy turning pale?")
                        .themedFont(.callout)
                        .themedForeground(.textMuted)
                }
                Spacer(minLength: 8)
                if phase == .idle || phase == .answered {
                    Button(phase == .answered ? "Again" : "Ask") { ask() }
                        .buttonStyle(.themed(.primary))
                        .frame(minHeight: 44)
                        .accessibilityHint("Asks the plant helper about Ivy")
                }
            }

            switch phase {
            case .idle:
                EmptyView()
            case .solving:
                thinkingRow(.solving, "Looking at Ivy's last three check-ins")
            case .composing:
                thinkingRow(.composing, "Writing a short answer")
            case .answered:
                Text("Ivy sits 3 m from the window. Pothos pale out in low light: move it closer to the east window and skip the next watering.")
                    .themedFont(.body)
                    .themedForeground(.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder private var assistantFace: some View {
        if case .none = direction.assistant {
            // The brief asked for no assistant character; keep a plain glyph.
            Image(systemName: "sparkles")
                .font(.title2)
                .themedForeground(.primary)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
        } else {
            TouchAssistant(assistantState, size: 44)
                .frame(width: 44, height: 44)
                .accessibilityLabel("Plant helper")
                .accessibilityValue(phase == .solving || phase == .composing ? "Thinking" : "Ready")
        }
    }

    private var assistantState: TouchAssistantState {
        switch phase {
        case .solving, .composing: .working
        case .idle, .answered: .idle
        }
    }

    private func thinkingRow(_ state: OrbState, _ text: String) -> some View {
        HStack(spacing: 10) {
            TouchThinking(state, size: .small)
                .frame(width: 32, height: 32)
            Text(text)
                .themedFont(.callout)
                .themedForeground(.textMuted)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .transition(.opacity)
    }

    private func ask() {
        phase = .solving
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            phase = .composing
            try? await Task.sleep(for: .seconds(1))
            phase = .answered
        }
    }

    // MARK: Plants

    private var plants: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Your plants")
                .accessibilityAddTraits(.isHeader)
            ForEach(Plant.samples) { plant in
                PlantCard(plant: plant)
            }
        }
    }

    // MARK: Onboarding

    private var onboarding: some View {
        TouchCard(expressive: true) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add your next plant")
                    .themedFont(.headline)
                    .accessibilityAddTraits(.isHeader)
                Text("Snap a photo and Tend works out the species, the light it likes and when to water.")
                    .themedFont(.body)
                    .fixedSize(horizontal: false, vertical: true)
                TouchButton("Add a plant", expressive: true) {}
                TouchButton("Not now", role: .secondary, expressive: true) {
                    showOnboarding = false
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PlantCard: View {
    let plant: Plant

    var body: some View {
        TouchCard {
            HStack(spacing: 12) {
                Image(systemName: plant.symbol)
                    .font(.title3)
                    .themedForeground(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.tint.opacity(0.14)))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(plant.name).themedFont(.headline)
                    Text(plant.note)
                        .themedFont(.callout)
                        .themedForeground(.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                badge
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plant.name), \(plant.species). \(plant.note). \(statusText)")
    }

    private var statusText: String {
        switch plant.status {
        case .thirsty: "Water today"
        case .happy: "Happy"
        case .checkLight: "Check light"
        }
    }

    private var badge: some View {
        switch plant.status {
        case .thirsty: ThemedBadge(statusText, tone: .warning)
        case .happy: ThemedBadge(statusText, tone: .success)
        case .checkLight: ThemedBadge(statusText, tone: .neutral)
        }
    }
}
