import HumanTouch
import SwiftUI

/// The control panel: a native Form that edits the human brief live.
/// Deliberately not themed, so it reads as a tool beside the sample app.
struct BriefView: View {
    @Binding var profile: TouchProfile
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var direction: TouchDirection { TouchDirection(profile) }

    /// Index into `TouchProfile.presets`, or -1 once the sliders move off a preset.
    private var presetIndex: Binding<Int> {
        Binding(
            get: { TouchProfile.presets.firstIndex(of: profile) ?? -1 },
            set: { if TouchProfile.presets.indices.contains($0) { profile = TouchProfile.presets[$0] } }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if sizeClass == .regular {
                    HStack(spacing: 0) {
                        Form { controlSections }
                        Form { whySection }
                    }
                } else {
                    Form {
                        controlSections
                        whySection
                    }
                }
            }
            .navigationTitle("Brief")
        }
    }
}

struct AxisSlider: View {
    let title: String
    let low: String
    let high: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(value, format: .percent.precision(.fractionLength(0)))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: 0...1) {
                Text(title)
            } minimumValueLabel: {
                Text(low).font(.caption).foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text(high).font(.caption).foregroundStyle(.secondary)
            }
            .accessibilityValue("\(Int((value * 100).rounded())) percent, from \(low) to \(high)")
        }
        .padding(.vertical, 4)
    }
}

extension BriefView {
    @ViewBuilder var controlSections: some View {
                Section {
                    Picker("Preset", selection: presetIndex) {
                        ForEach(TouchProfile.presets.indices, id: \.self) { i in
                            Text(TouchProfile.presets[i].name).tag(i)
                        }
                        if presetIndex.wrappedValue == -1 {
                            Text("Custom").tag(-1)
                        }
                    }
                    if !profile.audience.isEmpty {
                        LabeledContent("For", value: profile.audience)
                    }
                    if !profile.feeling.isEmpty {
                        LabeledContent("Should feel", value: profile.feeling)
                    }
                } header: {
                    Text("Who it's for")
                }

                Section("Feel") {
                    AxisSlider(title: "Energy", low: "Calm", high: "Lively", value: $profile.energy)
                    AxisSlider(title: "Warmth", low: "Cool", high: "Warm", value: $profile.warmth)
                    AxisSlider(title: "Craft", low: "Machined", high: "Handmade", value: $profile.craft)
                }

                Section("Context") {
                    Picker("Stakes", selection: $profile.stakes) {
                        ForEach(TouchProfile.Stakes.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    Picker("Moment", selection: $profile.moment) {
                        ForEach(TouchProfile.Moment.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    Picker("Assistant", selection: $profile.assistant) {
                        ForEach(TouchProfile.AssistantPresence.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                }

    }

    var whySection: some View {
                Section {
                    LabeledContent("Style", value: direction.theme.name)
                    LabeledContent("Hand-drawn", value: direction.handDrawn.label)
                    LabeledContent("Assistant", value: direction.assistant.label)
                    LabeledContent("Haptics", value: direction.haptics.rawValue.capitalized)
                    ForEach(direction.rationale, id: \.self) { reason in
                        Label {
                            Text(reason).fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "text.quote").foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Why it looks like this")
                }
    }
}

extension TouchDirection.HandDrawn {
    var label: String {
        switch self {
        case .none: "None"
        case .accents: "Pen accents"
        case .controls: "Sketched controls"
        }
    }
}

extension TouchDirection.Assistant {
    var label: String {
        switch self {
        case .none: "None"
        case .orb: "Thinking orb"
        case let .bot(persona): "\(persona.type.capitalized) bot"
        }
    }
}
