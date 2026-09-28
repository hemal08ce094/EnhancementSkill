import HumanTouch
import SwiftUI

/// Launch arguments (read through UserDefaults' argument domain):
///   -profile calm|trusted|playful|bold   start on a preset brief
///   -tab app|brief                        start on a tab
///   -scheme dark|light                    force the color scheme
///   -ask thinking|answer                  pre-set the helper flow (for screenshots)
@main
struct EnhancementDemoApp: App {
    @State private var model = DemoModel.fromLaunchArguments()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .preferredColorScheme(model.forcedScheme)
        }
    }
}

enum DemoTab: String, Hashable { case app, brief }

@Observable
@MainActor
final class DemoModel {
    var profile: TouchProfile
    var tab: DemoTab
    var forcedScheme: ColorScheme?
    var initialAsk: AskPhase

    init(profile: TouchProfile, tab: DemoTab, forcedScheme: ColorScheme?, initialAsk: AskPhase) {
        self.profile = profile
        self.tab = tab
        self.forcedScheme = forcedScheme
        self.initialAsk = initialAsk
    }

    static func fromLaunchArguments() -> DemoModel {
        let defaults = UserDefaults.standard
        let profile: TouchProfile = switch defaults.string(forKey: "profile")?.lowercased() {
        case "calm": .calmCompanion
        case "playful": .playfulMaker
        case "bold": .boldPerformer
        default: .trustedTool
        }
        let tab = DemoTab(rawValue: defaults.string(forKey: "tab")?.lowercased() ?? "") ?? .app
        let scheme: ColorScheme? = switch defaults.string(forKey: "scheme")?.lowercased() {
        case "dark": .dark
        case "light": .light
        default: nil
        }
        let ask: AskPhase = switch defaults.string(forKey: "ask")?.lowercased() {
        case "thinking": .solving
        case "answer": .answered
        default: .idle
        }
        return DemoModel(profile: profile, tab: tab, forcedScheme: scheme, initialAsk: ask)
    }
}

struct RootView: View {
    @Bindable var model: DemoModel

    var body: some View {
        TabView(selection: $model.tab) {
            Tab("App", systemImage: "leaf", value: DemoTab.app) {
                // The sample product, dressed by the brief.
                TendTodayView(initialAsk: model.initialAsk)
                    .humanTouch(model.profile)
            }
            Tab("Brief", systemImage: "slider.horizontal.3", value: DemoTab.brief) {
                // The control panel stays native on purpose.
                BriefView(profile: $model.profile)
            }
        }
    }
}
